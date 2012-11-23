//
//  main.cpp
//  audio
//
//  Created by 黄 扬奇 on 12-11-23.
//  Copyright (c) 2012年 黄 扬奇. All rights reserved.
//

#include <iostream>
#include <portaudio.h>
#include <pthread.h>
#include <list>
#include <semaphore.h>
extern "C" {
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libavutil/samplefmt.h>
}

#define min(a,b) (a)>(b)?(b):(a)

using namespace std;

#define BUFSIZE 2*1024*1024

typedef struct {
    uint8_t * buf[2];
    int bufid,bufindex;
    AVFormatContext *pFmtCtx;
    AVCodecContext *pCodecCtx;
} UserData;

sem_t *demand,*product;


void *decode(void *arg)
{
    UserData *userData = (UserData*)arg;
    int got,bufpos = 0;
    int bufid = 0;
    int p;
    while(1) {
        AVFrame *pkt = avcodec_alloc_frame();
        AVPacket pkt_tmp;
        if(av_read_frame(userData->pFmtCtx, &pkt_tmp) < 0) {
            break;
        }
        avcodec_decode_audio4(userData->pCodecCtx, pkt, &got, &pkt_tmp);
        int s = pkt->nb_samples* pkt->channels * 2;
        while(s > 0) {
            int ss = min(s,BUFSIZE - bufpos);
            memcpy(userData->buf[bufid] + bufpos, pkt->data[0], ss);
            bufpos += ss;
            s -= ss;
            if(bufpos >= BUFSIZE) {
                bufpos = 0;
                bufid ^= 1; //切换buf
                sem_post(product);
                sem_wait(demand);
            }
        }
        
        avcodec_free_frame(&pkt);
    }
    
    
    return 0;
}

void destroy(void)
{
    sem_destroy(product);
    sem_destroy(demand);
    
    cerr << "aaaa";
}

#define sample_format int16_t

static int streamCallback( const void *inputBuffer, void *outputBuffer,
                          unsigned long framesPerBuffer,
                          const PaStreamCallbackTimeInfo* timeInfo,
                          PaStreamCallbackFlags statusFlags,
                          void *data )
{
    UserData *userData = (UserData*)data;
    sample_format *out = (sample_format*)outputBuffer;
    sample_format *buf = (sample_format*)(userData->buf[userData->bufid]+userData->bufindex);
    for (int i = 0; i < framesPerBuffer; ++i) {
        *out++ = *buf++;
        *out++ = *buf++;
        userData->bufindex += 2*sizeof(sample_format);
        if(userData->bufindex>=BUFSIZE) {
            sem_post(demand);
            sem_wait(product);
            userData->bufindex = 0;
            userData->bufid ^= 1;
        }
    }
    return 0;
}

int main(int argc, const char * argv[])
{
    sem_unlink("/audio/product");
    sem_unlink("/audio/demand");
    product = sem_open("/audio/product", O_CREAT | O_RDWR, S_IRUSR | S_IWUSR, 0);
    demand = sem_open("/audio/demand", O_CREAT | O_RDWR, S_IRUSR | S_IWUSR, 0);
    
    av_log_set_level(0);
    
    PaError err;
    err = Pa_Initialize();
    if( err != paNoError) {
        std::cerr << Pa_GetErrorText(err);
        return 1;
    }
    
    
    //open audio file
    av_register_all();
    AVFormatContext *pFmtCtx = avformat_alloc_context();
    if(avformat_open_input(&pFmtCtx, argv[1], NULL, NULL) < 0) {
        std::cerr << "cannot open input";
        return 1;
    }
    //av_dump_format(pFmtCtx, 0, NULL, 0);
    
    //get stream info
    if(avformat_find_stream_info(pFmtCtx, NULL)<0){
        std::cerr << "cannot find stream info";
        return 1;
    }
    
    av_dump_format(pFmtCtx, 0, NULL, 0);
    
    //find best stream
    int best_stream_index = 0;
    best_stream_index = av_find_best_stream(pFmtCtx, AVMEDIA_TYPE_AUDIO, 1, 0, NULL, 0);
    best_stream_index = best_stream_index < 0 ? 0 : best_stream_index;
    
    AVCodecContext *pCodecCtx = pFmtCtx->streams[best_stream_index]->codec;
    AVCodec *pCodec = avcodec_find_decoder(pCodecCtx->codec_id);
    avcodec_open2(pCodecCtx, pCodec, NULL);
    
    //fill userdata
    UserData *userData = (UserData*)malloc(sizeof(UserData));
    memset(userData, 0, sizeof(UserData));
    userData->pCodecCtx = pCodecCtx;
    userData->pFmtCtx = pFmtCtx;
    userData->buf[0] = (uint8_t*)malloc(BUFSIZE);
    userData->buf[1] = (uint8_t*)malloc(BUFSIZE);
    
    pthread_t pid;
    
    pthread_create(&pid, NULL, decode, userData);
    void *ret;
    
    PaStream *stream;
    err = Pa_OpenDefaultStream(&stream, 0, 2, paInt16, 24000, 512, streamCallback, userData);
    if( err != paNoError) {
        std::cerr << Pa_GetErrorText(err);
        return 1;
    }
    err = Pa_StartStream(stream);
    if( err != paNoError) {
        std::cerr << Pa_GetErrorText(err);
        return 1;
    }
    
    pthread_join(pid, &ret);

    return 0;
}

