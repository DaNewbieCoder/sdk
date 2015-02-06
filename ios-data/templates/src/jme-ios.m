/*
 * Copyright (c) 2009-2013 jMonkeyEngine
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 * * Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 *
 * * Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the distribution.
 *
 * * Neither the name of 'jMonkeyEngine' nor the names of its contributors
 *   may be used to endorse or promote products derived from this software
 *   without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
#include <jni.h>
#import <UIKit/UIKit.h>

/**
 * Author: Normen Hansen
 */

#ifndef JNIEXPORT
#define JNIEXPORT __attribute__ ((visibility("default"))) \
  __attribute__ ((used))
#endif

BOOL checkJNIException(JNIEnv *e){
    if ((*e)->ExceptionCheck(e)) {
        (*e)->ExceptionDescribe(e);
        (*e)->ExceptionClear(e);
        return YES;
    }
    return NO;
}

#ifndef _Included_com_jme3_system_ios_IosImageLoader
#define _Included_com_jme3_system_ios_IosImageLoader
#endif

JNIEXPORT jobject JNICALL
Java_com_jme3_system_ios_IosImageLoader_loadImageData(JNIEnv* e, jclass obj, jobject imageFormat, jobject inputStream){
    // prepare java classes and method pointers
    jclass imageClass = (*e)->FindClass(e, "com.jme3.texture.Image");
    jclass inputStreamClass = (*e)->FindClass(e, "java.io.InputStream");
    jclass bufferUtilsClass = (*e)->FindClass(e, "com.jme3.util.BufferUtils");
    jmethodID imageConstructor = (*e)->GetMethodID(e, imageClass, "<init>", "(Lcom/jme3/texture/Image$Format;IILjava/nio/ByteBuffer;)V");
    jmethodID readMethod = (*e)->GetMethodID(e, inputStreamClass, "read", "([B)I");
    jmethodID newBufferMethod = (*e)->GetStaticMethodID(e, bufferUtilsClass, "createByteBuffer", "(I)Ljava/nio/ByteBuffer;");
    if (checkJNIException(e)) {
        return nil;
    }
    // read data from inputstream via byteArray to NSMutableData
    jbyteArray tempArray = (*e)->NewByteArray (e, 1000);
    NSMutableData *inData = [[NSMutableData alloc] init];
    jint size = (*e)->CallIntMethod(e, inputStream, readMethod, tempArray);
    if (checkJNIException(e)) {
        [inData release];
        return nil;
    }
    while (size != -1) {
        jbyte *data;
        data = (*e)->GetByteArrayElements(e, tempArray, false);
        [inData appendBytes:data length:size];
        (*e)->ReleaseByteArrayElements(e, tempArray, data, JNI_ABORT);
        size = (*e)->CallIntMethod(e, inputStream, readMethod, tempArray);
        if (checkJNIException(e)) {
            [inData release];
            return nil;
        }
    }
    (*e)->DeleteLocalRef(e, tempArray);
    if (checkJNIException(e)) {
        [inData release];
        return nil;
    }
    // decode image data
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    UIImage* inputImage = [UIImage imageWithData:inData];
    if(inputImage == nil){
        [inData release];
        [pool release];
        return nil;
    }
    CGImageRef inImage = [inputImage CGImage];
    int wdth = CGImageGetWidth(inImage);
    int ht = CGImageGetHeight(inImage);
    // NewDirectByteBuffer seems to fail? -> Creating ByteBuffer in java
    jobject nativeBuffer = (*e)->CallStaticObjectMethod(e, bufferUtilsClass, newBufferMethod, ht*wdth*4);
    if (checkJNIException(e)) {
        [inData release];
        [pool release];
        return nil;
    }
    void *rawData = (*e)->GetDirectBufferAddress(e, nativeBuffer);
    NSUInteger bytesPerRowImg = CGImageGetBytesPerRow(inImage);
    NSUInteger bitsPerComponentImg = CGImageGetBitsPerComponent(inImage);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rawData,wdth,ht,bitsPerComponentImg,bytesPerRowImg,colorSpace,kCGImageAlphaPremultipliedLast| kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context,CGRectMake(0,0,wdth,ht), inImage);
    CGContextRelease(context);
    [inData release];
    [pool release];
    //create image
    jobject imageObject = (*e)->NewObject(e, imageClass, imageConstructor, imageFormat, wdth, ht, nativeBuffer);
    return imageObject;
}

#ifndef _Included_com_jme3_system_ios_JmeIosSystem
#define _Included_com_jme3_system_ios_JmeIosSystem
#endif

JNIEXPORT void JNICALL
Java_com_jme3_system_ios_JmeIosSystem_showDialog(JNIEnv* e, jobject c, jstring text) {
    const char* chars = (*e)->GetStringUTFChars(e, text, 0);
    NSString* string = [[NSString alloc] initWithUTF8String : chars];
    (*e)->ReleaseStringUTFChars(e, text, chars);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle : @"Error"
                                                    message : string
                                                   delegate : nil
                                          cancelButtonTitle : @"OK"
                                          otherButtonTitles : nil];
    [alert show];
    [alert release];
    [string release];
}
