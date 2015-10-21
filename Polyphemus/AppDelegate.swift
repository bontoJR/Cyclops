//
//  AppDelegate.swift
//  Polyphemus
//
//  Created by Junior B. on 02/10/15.
//  Copyright © 2015 Bonto.ch. All rights reserved.
//

import Cocoa
import AVFoundation

func performBlock(afterDelay delay:NSTimeInterval, queue: dispatch_queue_t = dispatch_get_main_queue(), block:() -> Void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), queue, block)
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, OverlayWindowDelegate {

    @IBOutlet weak var mainMenu: NSMenu!
    @IBOutlet weak var makeAreaFullscreenBtn: NSMenuItem!
    @IBOutlet weak var exitFullScreenBtn: NSMenuItem!
    
    var statusItem: NSStatusItem? = nil
    var mirrorWindow: NSWindow? = nil
    var fullScreenView: NSView? = nil
    
    var overlayWindow: OverlayWindow? = nil
    var infoView: InfoView? = nil
    var selectionView: SelectionView? = nil
    var cropRect: CGRect = CGRectZero
    
    var monitorCaptureSession: AVCaptureSession? = nil
    var movieFileOutput: AVCaptureMovieFileOutput? = nil
    var timer: NSTimer? = nil
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        
        let icon = NSImage(named: "icon")
        icon?.template = true
        
        statusItem?.image = icon
        statusItem?.menu = mainMenu
        
        exitFullScreenBtn.enabled = false
        makeAreaFullscreenBtn.enabled = false
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    /// Actions
    @IBAction func createSourceAreaClicked(sender: NSMenuItem) {
        guard let mainScreen = NSScreen.mainScreen() else {
            return;
        }
        
        overlayWindow = OverlayWindow(contentRect: mainScreen.frame,
            styleMask: NSBorderlessWindowMask,
            backing: .Buffered,
            `defer`: false,
            screen: mainScreen)
        
        overlayWindow?.overlayDelegate = self
        overlayWindow?.releasedWhenClosed = false
        
        overlayWindow?.showInfoView()
        overlayWindow?.infoView.textField.stringValue = NSLocalizedString("Start dragging to define an area", comment: "Explaining how to create a source area")
        
        overlayWindow?.makeKeyAndOrderFront(NSApp)
    }
    
    @IBAction func makeSourceAreaFullscreenClicked(sender: NSMenuItem) {
        monitorCaptureSession = AVCaptureSession()
        monitorCaptureSession?.sessionPreset = AVCaptureSessionPresetHigh
        
        let displayID = CGMainDisplayID()
        let input = AVCaptureScreenInput(displayID: displayID)
        input.cropRect = cropRect
        
        if monitorCaptureSession?.canAddInput(input) == true {
            monitorCaptureSession?.addInput(input)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: monitorCaptureSession)
        previewLayer.backgroundColor = NSColor.blackColor().CGColor
        
        let secondaryScreen = NSScreen.screens()?.filter() { screen in
            return screen != NSScreen.mainScreen()
        }.first
        
        if let secondaryScreen = secondaryScreen {
            mirrorWindow = NSWindow(contentRect: cropRect,
                styleMask: NSBorderlessWindowMask,
                backing: .Buffered,
                `defer`: false,
                screen: secondaryScreen)
            mirrorWindow?.releasedWhenClosed = false
            mirrorWindow?.makeKeyAndOrderFront(nil)
            
            if let frame = mirrorWindow?.contentView?.bounds {
                let previewLayerView = NSView(frame: frame)
                previewLayer.frame = frame
                previewLayerView.layer = previewLayer
                previewLayerView.wantsLayer = true
                mirrorWindow?.contentView?.addSubview(previewLayerView)
                
                previewLayerView.enterFullScreenMode(secondaryScreen,
                    withOptions: [NSFullScreenModeAllScreens: false])
                
                fullScreenView = previewLayerView
            }
            
            monitorCaptureSession?.startRunning()
            
            exitFullScreenBtn.enabled = true
            makeAreaFullscreenBtn.enabled = false
        }

    }
    
    @IBAction func exitFullscreenClicked(sender: NSMenuItem) {
        fullScreenView?.exitFullScreenModeWithOptions(nil)
        mirrorWindow?.close()
        fullScreenView = nil
        mirrorWindow = nil
        
        exitFullScreenBtn.enabled = false
        makeAreaFullscreenBtn.enabled = true
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }

    // MARK: Overlay Delegate
    func overlayWindowDidSelectRect(overlayWindow: OverlayWindow, rect: CGRect) {
        cropRect = rect
        
        self.overlayWindow!.close()
        self.overlayWindow = nil
        
        makeAreaFullscreenBtn.enabled = true
    }
}

