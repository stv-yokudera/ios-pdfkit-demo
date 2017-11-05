//
//  PDFViewController.swift
//  ios-pdfkit-demo
//
//  Created by OkuderaYuki on 2017/09/28.
//  Copyright © 2017年 OkuderaYuki. All rights reserved.
//

import PDFKit
import UIKit

final class PDFViewController: UIViewController {
    
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var pdfThumbnailView: PDFThumbnailView!
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ここに個別の
        setupPdfView()
        let pdfName = "test"
        navigationItem.title = pdfName
        showPDF(pdfName: pdfName)
        
        // 検索
        find(text: "3", document: pdfView.document!, delegate: self)
    }
}

extension PDFViewController {
    
    // MARK: - show
    
    func showPDF(pdfData: Data, usePageViewController: Bool = false) {
        pdfView.usePageViewController(usePageViewController)
        pdfView.document = PDFDocument(data: pdfData)
    }
    
    func showPDF(pdfUrl: URL, usePageViewController: Bool = false) {
        pdfView.usePageViewController(usePageViewController)
        pdfView.document = PDFDocument(url: pdfUrl)
    }
    
    /// PDFファイルのPATHを指定して、画面に表示する
    ///
    /// - Parameter pdfPath: PDFファイルのPATH
    func showPDF(pdfPath: String, usePageViewController: Bool = false) {
        if let fileHandle = FileHandle(forReadingAtPath: pdfPath) {
            let pdfData = fileHandle.readDataToEndOfFile()
            showPDF(pdfData: pdfData,
                    usePageViewController: usePageViewController)
        }
    }
    
    /// ResourcesのPDFファイル名を指定して、画面に表示する
    ///
    /// - Parameter pdfName: foo.pdfの場合 -> foo
    func showPDF(pdfName: String, usePageViewController: Bool = false) {
        if let pdfPath = Bundle.main.path(forResource: pdfName, ofType: "pdf") {
            showPDF(pdfPath: pdfPath,
                    usePageViewController: usePageViewController)
        }
    }
    
    // MARK: - configuration
    
    /// PDFViewの初期処理をする
    func setupPdfView() {
        
        // 初期表示が画面サイズにピッタリ収まるようにする
        pdfView.autoScales = true
        
        // サムネイルのセットアップ
        setupPdfThumbnailView(layoutMode: .vertical,
                              thumbnailSize: CGSize(width: 132, height: 66))
        
        // 余白を消す
//        pdfView.displaysPageBreaks = false
        
        // 余白を設定する
//        pageBreakMargins(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        
        // 背景色を設定
        pdfView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 0.8, alpha: 1)
        
        // スクロール方向に横向きを設定
        // pdfView.autoScalesがtrueで、スクロール方向を横向きにすると、
        // 小さく表示されてしまう
        displayDirection(direction: .vertical)
        
        displayMode(mode: .singlePageContinuous)
        displaysAsBook(true)
    }
    
    /// 任意の余白を設定する
    func pageBreakMargins(top: CGFloat,
                          left: CGFloat,
                          bottom: CGFloat,
                          right: CGFloat) {
        pdfView.displaysPageBreaks = true
        pdfView.pageBreakMargins = UIEdgeInsetsMake(top, left, bottom, right)
    }
    
    /// スクロールの方向を設定する
    ///
    /// - Parameter direction: PDFDisplayDirection
    func displayDirection(direction: PDFDisplayDirection) {
        pdfView.displayDirection = direction
    }
    
    /// 表示モードを設定する
    ///
    /// - Parameter mode: PDFDisplayMode
    func displayMode(mode: PDFDisplayMode = .singlePageContinuous) {
        pdfView.displayMode = mode
    }
    
    /// 見開きの時に最初のページを表紙として使用する
    ///
    /// 見開き（.twoUpContinuousまたは.twoUp）の場合のみ有効
    ///
    /// - Parameter asBook: true: 1ページ目を表紙とする, false: 表紙としない
    func displaysAsBook(_ asBook: Bool) {
        pdfView.displaysAsBook = asBook
    }
    
    // MARK: - thumbnail
    /// PDFViewの初期処理をする
    func setupPdfThumbnailView(layoutMode: PDFThumbnailLayoutMode = .vertical,
                               backgroundColor: UIColor = .lightGray,
                               thumbnailSize: CGSize = CGSize(width: 44.0, height: 44.0)) {
        pdfThumbnailView.pdfView = pdfView
        pdfThumbnailView.layoutMode = layoutMode
        pdfThumbnailView.backgroundColor = backgroundColor
        pdfThumbnailView.thumbnailSize = thumbnailSize
    }
    
    // MARK: - password
    
    func unlockPassword(password: String, document: PDFDocument) {
        let unlocked = document.unlock(withPassword: password)
        if unlocked {
            pdfView.document = document
        }
    }
    
    // MARK: - file operation
    
    /// ページ入れ替え
    func exchangePage(thePage: Int, otherPage: Int, document: PDFDocument) {
        document.exchangePage(at: thePage, withPageAt: otherPage)
        pdfView.document = document
    }
    
    /// ページ削除
    func removePage(thePage: Int, document: PDFDocument) {
        document.removePage(at: thePage)
    }
    
    /// PATHを指定して、ファイル保存
    func saveDocument(to path: String, document: PDFDocument) {
        document.write(toFile: path)
    }
    
    /// URLを指定して、ファイル保存
    func saveDocument(to url: URL, document: PDFDocument) {
        document.write(to: url)
    }
    
    // MARK: - search
    func find(text: String, document: PDFDocument, delegate: PDFDocumentDelegate) {
        document.delegate = delegate
        document.beginFindString(text, withOptions: .caseInsensitive)
        pdfView.document = document
    }
}

extension PDFViewController: PDFDocumentDelegate {
    func didMatchString(_ instance: PDFSelection) {
        
        instance.color = .blue
        
//        let marker = UIView(frame: instance.bounds(for: pdfView.currentPage!))
//        marker.backgroundColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
//        marker.alpha = 0.5
//        pdfView.addSubview(marker)
    }
}
