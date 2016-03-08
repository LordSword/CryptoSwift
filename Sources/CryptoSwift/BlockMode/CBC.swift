//
//  CBC.swift
//  CryptoSwift
//
//  Created by Marcin Krzyzanowski on 08/03/16.
//  Copyright © 2016 Marcin Krzyzanowski. All rights reserved.
//
//  Cipher-block chaining (CBC)
//

struct CBCModeEncryptGenerator: CipherModeGenerator {
    typealias Element = Array<UInt8>
    let options: BlockModeOptions = [.InitializationVectorRequired, .PaddingRequired]

    private let iv: Element
    private let inputGenerator: AnyGenerator<Element>

    private let cipherOperation: CipherOperationOnBlock
    private var prevCiphertext: Element?

    init(iv: Array<UInt8>, cipherOperation: CipherOperationOnBlock, inputGenerator: AnyGenerator<Array<UInt8>>) {
        self.iv = iv
        self.cipherOperation = cipherOperation
        self.inputGenerator = inputGenerator
    }

    mutating func next() -> Element? {
        guard let plaintext = inputGenerator.next(),
              let encrypted = cipherOperation(block: xor(prevCiphertext ?? iv, plaintext))
        else {
            return nil
        }

        self.prevCiphertext = encrypted
        return encrypted
    }
}

struct CBCModeDecryptGenerator: CipherModeGenerator {
    typealias Element = Array<UInt8>
    let options: BlockModeOptions = [.InitializationVectorRequired, .PaddingRequired]

    private let iv: Element
    private let inputGenerator: AnyGenerator<Element>

    private let cipherOperation: CipherOperationOnBlock
    private var prevCiphertext: Element?

    init(iv: Array<UInt8>, cipherOperation: CipherOperationOnBlock, inputGenerator: AnyGenerator<Element>) {
        self.iv = iv
        self.cipherOperation = cipherOperation
        self.inputGenerator = inputGenerator
    }

    mutating func next() -> Element? {
        guard let ciphertext = inputGenerator.next(),
              let decrypted = cipherOperation(block: ciphertext)
        else {
            return nil
        }

        let result = xor(prevCiphertext ?? iv, decrypted)
        self.prevCiphertext = ciphertext
        return result
    }
}
