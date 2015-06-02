//
//  AppDelegate.swift
//  SwiftLinksMenuBar
//
//  Created by Timothy Dang on 28/05/2015.
//  Copyright (c) 2015 Timothy Dang. All rights reserved.
//

import Cocoa
import SwiftyJSON

struct MenuBarItem:NilLiteralConvertible {
    let title:String?
    let url:String?
    let items:Array<MenuBarItem>
    
    init(nilLiteral: ()) {
        self.title  = nil
        self.url   = nil
        self.items  = []
    }
    
    init(title: String?, url: String?, items: Array<MenuBarItem>) {
        self.title  = title
        self.url   = url
        self.items  = items
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    var statusBarItem: NSStatusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    var menu = NSMenu()
    var menuItems:Array<MenuBarItem> = []
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let icon = NSImage(named: "statusIcon")
        icon?.setTemplate(true)
        self.statusBarItem.image = icon

        NSApp.setActivationPolicy(NSApplicationActivationPolicy.Accessory)
        
        parseJson()
        initMenu()
    }
    
    func parseJson() {
        let bundle = NSBundle.mainBundle()
        let path = bundle.pathForResource("links", ofType: "json")
        var error:NSError?
        let data: NSData? = NSData(contentsOfFile: path!)
        
        let content = JSON(data: data!, options: NSJSONReadingOptions.allZeros, error: &error)
        var json = content.dictionary! as Dictionary<String, JSON>
        let values = json.values.first?.array!
        
        for i in 0...((values?.count)!-1) {
            var itemJSON = values?[i] as JSON?
            
            var itemName = itemJSON?.dictionary?.keys.first
            var itemLink = itemJSON?.dictionary?.values.array as Array?
            
            var menuItem:MenuBarItem = nil
            var childMenuItems:Array<MenuBarItem> = []
            
            if itemName == nil {
                menuItems.append(nil)
            }
            
            if(itemLink?.first?.array != nil) {
                
                // Having child menu items
                var subItems = itemLink?.first?.array
                var subItem:MenuBarItem = nil
                for j in 0...(subItems?.count)!-1 {
                    var subItemJSON = subItems?[j] as JSON?
                    
                    var subItemName = subItemJSON?.dictionary?.keys.first
                    var subItemLink = subItemJSON?.dictionary?.values.first?.string
                    
                    subItem = MenuBarItem(title: subItemName, url: subItemLink, items: [])
                    childMenuItems.append(subItem)
                }
                
            }
            
            menuItem = MenuBarItem(title: itemName, url: itemLink?.first?.string, items: childMenuItems)
            menuItems.append(menuItem)
        }
    }
    
    func initMenu() {
        for i in 0...self.menuItems.count-1 {
            var item = self.menuItems[i] as MenuBarItem
            
            if item.items.count > 0 {
                let subMenu = NSMenu()
                
                for j in 0...item.items.count-1 {
                    var subMenuItem = NSMenuItem(title: item.items[j].title!, action: Selector("clickMenuItem:"), keyEquivalent: "")
                    subMenuItem.representedObject = item.items[j].url
                    subMenu.addItem(subMenuItem)
                }
                var menuItem = NSMenuItem(title: item.title!, action: nil, keyEquivalent: "")
                menuItem.submenu = subMenu
                menu.addItem(menuItem)
            } else if item.title == nil {
                menu.addItem(NSMenuItem.separatorItem())
            } else {
                var menuItem = NSMenuItem(title: item.title!, action: Selector("clickMenuItem:"), keyEquivalent: "")
                menuItem.representedObject = item.url
                menu.addItem(menuItem)
            }
            
        }
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItemWithTitle("Quit", action: Selector("terminate:"), keyEquivalent: "")
        
        self.statusBarItem.menu = menu
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func clickMenuItem(sender: NSMenuItem) {
        var itemUrl = sender.representedObject as! String
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: itemUrl)!)
    }
}


