//
//  XcodeUtils.m
//  XVim2
//
//  Created by Ant on 09/10/2017.
//  Copyright © 2017 Shuichiro Suzuki. All rights reserved.
//

#import "XcodeUtils.h"
#import "IDEWorkspaceTabController+XVim.h"
#import <IDEKit/IDEWorkspaceWindow.h>
#import <IDEKit/IDEEditorContext.h>
#import <IDEKit/IDEEditorOpenSpecifier.h>
#import <IDEKit/IDEEditorArea.h>
#import <IDEKit/IDEWorkspaceWindowController.h>
#import <IDEKit/IDEWorkspaceTabController.h>
#import <IDEKit/IDEEditorOpenSpecifier.h>
#import <DVTKit/DVTDocumentLocation.h>

Class IDEEditorOpenSpecifierClass() { return NSClassFromString(@"IDEEditorOpenSpecifier"); }
Class DVTDocumentLocationClass() { return NSClassFromString(@"DVTDocumentLocation"); }
Class IDEWorkspaceWindowClass() { return NSClassFromString(@"IDEWorkspaceWindow"); }

IDEWorkspaceWindowController* XVimLastActiveWindowController()
{
    return [IDEWorkspaceWindowClass() lastActiveWorkspaceWindowController];
}

IDEWorkspaceTabController_XVim* XVimLastActiveWorkspaceTabController()
{
    return (IDEWorkspaceTabController_XVim*)[XVimLastActiveWindowController() activeWorkspaceTabController];
}

IDEEditorArea* XVimLastActiveEditorArea() { return [XVimLastActiveWindowController() editorArea]; }


BOOL XVimOpenDocumentAtPath(NSString *path) {
    NSError* error;
    NSURL* doc = [NSURL fileURLWithPath:path];
    DVTDocumentLocation* loc = [[DVTDocumentLocationClass() alloc] initWithDocumentURL:doc timestamp:nil];
    if (loc) {
        IDEEditorOpenSpecifier* spec = [IDEEditorOpenSpecifierClass()
                                        structureEditorOpenSpecifierForDocumentLocation:loc
                                        inWorkspace:[XVimLastActiveWindowController().activeWorkspaceTabController workspace]
                                        error:&error];
        if (error == nil) {
            [XVimLastActiveEditorArea() _openEditorOpenSpecifier:spec
                                                   editorContext:[XVimLastActiveEditorArea() lastActiveEditorContext]
                                                       takeFocus:YES];
        }
        else {
            ERROR_LOG(@"Failed to create IDEEditorOpenSpecifier from %@. Error = %@", path, error.localizedDescription);
            return NO;
        }
    }
    else {
        ERROR_LOG(@"Cannot create DVTDocumentLocation from %@", path);
        return NO;
    }
    return YES;
}


IDEEditorOpenSpecifier *XVimOpenSpecifier(IDENavigableItem *item, id locationToSelect)
{
    NSError *err = nil;
    IDEEditorOpenSpecifier * spec = locationToSelect
                        ? [[IDEEditorOpenSpecifierClass() alloc] initWithNavigableItem:item
                                                               locationToSelect:locationToSelect
                                                                          error:&err]
                        : [[IDEEditorOpenSpecifierClass() alloc] initWithNavigableItem:item error:&err];
    if (!spec || err != nil) {
        ERROR_LOG(@"Could not create IDEEditorOpenSpecifier. Error = %@", err.localizedDescription);
        return nil;
    }
    return spec;
}
