// Adding Login Items Using a Shared File List
// This is a combination of the code provided by the following Stackoverflow discussion
// http://stackoverflow.com/questions/26475008/swift-getting-a-mac-app-to-launch-on-startup
// (This approach will not work with App-Sandboxing.)

import Foundation

func applicationIsInStartUpItems() -> Bool {
    return itemReferencesInLoginItems().existingReference != nil
}

func setLaunchAtStartup(launchOnStartup: Bool) {
    let itemReferences = itemReferencesInLoginItems()
    let isNotAlreadySet = (itemReferences.existingReference == nil)
    let loginItemsRef = LSSharedFileListCreate(
        nil,
        kLSSharedFileListSessionLoginItems.takeRetainedValue(),
        nil).takeRetainedValue() as LSSharedFileListRef?
  
    if loginItemsRef != nil {
        if isNotAlreadySet && launchOnStartup {
            if let appUrl: CFURLRef = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath) {
                LSSharedFileListInsertItemURL(loginItemsRef, itemReferences.lastReference, nil, nil, appUrl, nil, nil)
                print("Application was added to login items")
            }
        } else if !isNotAlreadySet && !launchOnStartup {
            if let itemRef = itemReferences.existingReference {
                LSSharedFileListItemRemove(loginItemsRef,itemRef);
                print("Application was removed from login items")
            }
        }
    }
}

func itemReferencesInLoginItems() -> (existingReference: LSSharedFileListItemRef?, lastReference:   LSSharedFileListItemRef?) {
    let itemUrl = UnsafeMutablePointer<Unmanaged<CFURL>?>.alloc(1)
    let appUrl = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath)
    let loginItemsRef = LSSharedFileListCreate(
        nil,
        kLSSharedFileListSessionLoginItems.takeRetainedValue(),
        nil
        ).takeRetainedValue() as LSSharedFileListRef?
    
    if loginItemsRef != nil {
        let loginItems = LSSharedFileListCopySnapshot(loginItemsRef, nil).takeRetainedValue() as NSArray
        print("There are \(loginItems.count) login items")
        
        if(loginItems.count > 0) {
            let lastItemRef = loginItems.lastObject as! LSSharedFileListItemRef
            
            for var i = 0; i < loginItems.count; ++i {
                let currentItemRef = loginItems.objectAtIndex(i) as! LSSharedFileListItemRef
                
                if LSSharedFileListItemResolve(currentItemRef, 0, itemUrl, nil) == noErr {
                    if let urlRef: NSURL = itemUrl.memory?.takeRetainedValue() {
                        print("URL Ref: \(urlRef.lastPathComponent)")
                        if urlRef.isEqual(appUrl) {
                            return (currentItemRef, lastItemRef)
                        }
                    }
                }
                else {
                    print("Unknown login application")
                }
            }
            // The application was not found in the startup list
            return (nil, lastItemRef)
            
        } else {
            let addatstart: LSSharedFileListItemRef = kLSSharedFileListItemBeforeFirst.takeRetainedValue()
            return(nil,addatstart)
        }
    }
  
    return (nil, nil)
}