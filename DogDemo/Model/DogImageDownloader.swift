//
//  DogImageDownloader.swift
//  DogDemo
//
//  Created by Nathan Wallace on 3/24/18.
//  Copyright © 2018 Nathan Wallace. All rights reserved.
//
//  Reference: https://krakendev.io/blog/the-right-way-to-write-a-singleton

import AlamofireImage


class DogImageDownloader {
    static let shared = ImageDownloader(
        configuration: ImageDownloader.defaultURLSessionConfiguration(),
        downloadPrioritization: .fifo,
        maximumActiveDownloads: 4,
        imageCache: AutoPurgingImageCache()
    )
    private init() {} //This prevents others from using the default '()' initializer for this class.
}
