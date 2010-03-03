﻿// preferences class// (cc)2007-2010 codeplay// By Jam Zhang// jammind@gmail.compackage {	import flash.display.NativeWindow;	import flash.display.NativeMenu;	import flash.display.NativeMenuItem;	import flash.display.DisplayObject;	import flash.display.Sprite;	import flash.display.MovieClip;	import flash.display.SimpleButton;	import flash.desktop.NativeApplication;	import flash.events.Event;	import flash.events.MouseEvent;	import flash.geom.Rectangle;	import flash.system.System;	import codeplay.ui.aqua.scrollPanel;	import codeplay.event.customEvent;	import com.google.analytics.GATracker;	import caurina.transitions.Tweener;	public class preferences extends Sprite {		const MARGIN_TOP:int=80;		const MARGIN_BOTTOM:int=50;		public static const MIN_HEIGHT:int=360;		public static const MAX_HEIGHT:int=600;		public var shell:pixusShell;		var presets:scrollPanel;		var skins:scrollPanel;		var currentPanel:int=0;		var panelsX0:int;		private var tracker:GATracker=pixusShell.tracker;		function preferences(pshell:pixusShell):void {			shell=pshell;			addEventListener(Event.ADDED_TO_STAGE, init);		}		public function init(event:Event):void {			var l,n:int;			trace('preferences.init()');						maskPanel.width=bg.width=pixusShell.PREFERENCES_PANEL_WIDTH;			resizer.x=int(bg.width*.5);//			trace('preferences x='+pixusShell.options.preferencesWindow.x+' y='+pixusShell.options.preferencesWindow.y+' height='+pixusShell.options.preferencesWindow.height+' visible='+pixusShell.options.preferencesWindow.visible);			if(pixusShell.options.preferencesWindow.height!=undefined)				setHeight(pixusShell.options.preferencesWindow.height);			if (pixusShell.options.preferencesWindow!=undefined) {				stage.nativeWindow.x=pixusShell.options.preferencesWindow.x;				stage.nativeWindow.y=pixusShell.options.preferencesWindow.y;			}			stage.nativeWindow.visible=pixusShell.options.preferencesWindow.visible;			bClose.addEventListener(MouseEvent.CLICK, handleClose);			bg.addEventListener(MouseEvent.MOUSE_DOWN,handleMove);			bTabPresets.addEventListener(MouseEvent.CLICK, handleTab);			bTabSkins.addEventListener(MouseEvent.CLICK, handleTab);			bTabOptions.addEventListener(MouseEvent.CLICK, handleTab);			bTabHelp.addEventListener(MouseEvent.CLICK, handleTab);			bTabAbout.addEventListener(MouseEvent.CLICK, handleTab);			resizer.addEventListener(MouseEvent.MOUSE_DOWN, handleResize);			iconPresets.activate();			//panelArray=[panels.panelPresets,panels.panelSkins];			panelsX0=panels.x;			// Presets Panel			panels.panelPresets.bottomControl.bAdd.addEventListener(MouseEvent.CLICK, handleAdd);			panels.panelPresets.bottomControl.bReset.addEventListener(MouseEvent.CLICK, handleResetPresets);			rebuildPresets();			// Options Panel			panels.panelOptions.inner.cbAlwaysInFront.checked=pixusShell.options.alwaysInFront;			panels.panelOptions.inner.cbAlwaysInFront.addEventListener(MouseEvent.CLICK, handleOptionCheckBox);			try{ // Feature unavailable under IDE debugger				panels.panelOptions.inner.cbStartAtLogin.checked=NativeApplication.nativeApplication.startAtLogin;			}catch(error){}			panels.panelOptions.inner.cbStartAtLogin.addEventListener(MouseEvent.CLICK, handleOptionCheckBox);			panels.panelOptions.inner.cbShowQuickGuides.checked=pixusShell.options.showQuickGuides;			panels.panelOptions.inner.cbShowQuickGuides.addEventListener(MouseEvent.CLICK, handleOptionCheckBox);			// Skins Panel			panels.panelSkins.bottomControl.bFind.addEventListener(MouseEvent.CLICK, handleFindBackButton);			skins=new scrollPanel({width:pixusShell.PREFERENCES_PANEL_WIDTH});			panels.panelSkins.addChild(skins);			l=pixusShell.skinpresets.skin.length();			for (n=0; n<l; n++) {				skins.addChild(new skinRow());			}			// About Panel			panels.panelAbout.bottomControl.bUpdate.addEventListener(MouseEvent.CLICK, handleUpdate);			panels.panelAbout.inner.tfVersion.text=pixusShell.options.version.version;			panels.panelAbout.inner.tfRelease.text=pixusShell.options.version.release;			panels.panelAbout.inner.tfDate.text=pixusShell.options.version.date;			panels.panelAbout.inner.tfRuntime.text=NativeApplication.nativeApplication.runtimeVersion;			NativeApplication.nativeApplication.addEventListener(pixusShell.EVENT_PRESETS_CHANGE, handlePresetsChange);			NativeApplication.nativeApplication.addEventListener(pixusShell.EVENT_FIND_BACK,handleFindBackEvent);			NativeApplication.nativeApplication.addEventListener(pixusShell.EVENT_TOGGLE_GUIDES, handleToggleGuides, false, -10);			// Process toggle after the pixusMain logic						removeEventListener(Event.ADDED_TO_STAGE, init);			addEventListener(Event.ENTER_FRAME,init2);			addEventListener(Event.REMOVED_FROM_STAGE, dispose);		}		public function dispose(event:Event):void {			trace('preferences.dispose()');			removeEventListener(Event.REMOVED_FROM_STAGE, dispose);			//addEventListener(Event.ADDED_TO_STAGE, init);						// Generic listener removal			bClose.removeEventListener(MouseEvent.CLICK, handleClose);			bg.removeEventListener(MouseEvent.MOUSE_DOWN,handleMove);			bTabPresets.removeEventListener(MouseEvent.CLICK, handleTab);			bTabSkins.removeEventListener(MouseEvent.CLICK, handleTab);			bTabOptions.removeEventListener(MouseEvent.CLICK, handleTab);			bTabHelp.removeEventListener(MouseEvent.CLICK, handleTab);			bTabAbout.removeEventListener(MouseEvent.CLICK, handleTab);			resizer.removeEventListener(MouseEvent.MOUSE_DOWN, handleResize);						// Presets Panel			panels.panelPresets.bottomControl.bAdd.removeEventListener(MouseEvent.CLICK, handleAdd);			panels.panelPresets.bottomControl.bReset.removeEventListener(MouseEvent.CLICK, handleResetPresets);			removePresets();						// Options Panel			panels.panelOptions.inner.cbAlwaysInFront.removeEventListener(MouseEvent.CLICK, handleOptionCheckBox);			panels.panelOptions.inner.cbStartAtLogin.removeEventListener(MouseEvent.CLICK, handleOptionCheckBox);			panels.panelOptions.inner.cbShowQuickGuides.removeEventListener(MouseEvent.CLICK, handleOptionCheckBox);						// Skins Panel			panels.panelSkins.bottomControl.bFind.removeEventListener(MouseEvent.CLICK, handleFindBackButton);			panels.panelSkins.removeChild(skins);			skins=null;			menuRow.clearRows(skinRow.MENU_GROUP_NAME);						// About Panel			panels.panelAbout.bottomControl.bUpdate.removeEventListener(MouseEvent.CLICK, handleUpdate);			NativeApplication.nativeApplication.removeEventListener(pixusShell.EVENT_PRESETS_CHANGE, handlePresetsChange);			NativeApplication.nativeApplication.removeEventListener(pixusShell.EVENT_FIND_BACK,handleFindBackEvent);			NativeApplication.nativeApplication.removeEventListener(pixusShell.EVENT_TOGGLE_GUIDES, handleToggleGuides, false);			System.gc();		}				// Things must be done 1-frame after init()		function init2(event:Event):void {			removeEventListener(Event.ENTER_FRAME,init2);			syncWindowSize();		}				function handleOptionCheckBox(event:MouseEvent):void {			switch(event.target){				case panels.panelOptions.inner.cbAlwaysInFront:					tracker.trackPageview('Preferences/Options/AlwaysInFront/'+event.target.checked);					shell.alwaysInFront=event.target.checked;					break;				case panels.panelOptions.inner.cbStartAtLogin:					tracker.trackPageview('Preferences/Options/StartAtLogin/'+event.target.checked);					NativeApplication.nativeApplication.startAtLogin=event.target.checked;					break;				case panels.panelOptions.inner.cbShowQuickGuides:					tracker.trackPageview('Preferences/Options/ShowQuickGuides/'+event.target.checked);					NativeApplication.nativeApplication.dispatchEvent(new customEvent(pixusShell.EVENT_TOGGLE_GUIDES,{visible:event.target.checked,target:this}));					break;			}		}				public function handleToggleGuides(event:customEvent=null):void {			if(event.data.target!=this) { // In case triggered by the hotkey.				panels.panelOptions.inner.cbShowQuickGuides.checked=pixusShell.options.showQuickGuides;			}		}		function handleFindBackEvent(event:customEvent):void {			setHeight(MIN_HEIGHT);			syncWindowSize();		}		function handleFindBackButton(event:MouseEvent):void {			tracker.trackPageview('Preferences/Skins/FindPanels');			// Strange! The handler accepts an Event parameter but I have to trigger a customEvent or I will get a runtime error.			NativeApplication.nativeApplication.dispatchEvent(new customEvent(pixusShell.EVENT_FIND_BACK));		}		function handleResetPresets(event:MouseEvent):void {			if (event.shiftKey&&event.altKey&&event.ctrlKey) {				// Manually purge the settings				tracker.trackPageview('Preferences/Presets/ResetAndPurgeSettings');				trace('Manually Purge Settings');				pixusShell.so.clear();			} else {				// Just reset presets				tracker.trackPageview('Preferences/Presets/Reset');				NativeApplication.nativeApplication.dispatchEvent(new Event(pixusShell.EVENT_RESET_PRESETS));			}		}		function handleUpdate(event:Event):void {			tracker.trackPageview('Preferences/About/Update');			shell.toggleUpdateWindow(true);		}		function handlePresetsChange(event:Event):void {			rebuildPresets();			syncWindowSize();		}		function rebuildPresets():void {			var l,n:int;			if(presets!=null){				panels.panelPresets.removeChild(presets);				//menuRow.clearRows();			}			presets=new scrollPanel({width:pixusShell.PREFERENCES_PANEL_WIDTH,viewHeight:pixusShell.options.preferencesWindow.height,delta:pixusShell.PRESET_ROW_HEIGHT,snapping:true});			panels.panelPresets.addChild(presets);			l=pixusShell.options.presets.length;			for (n=0; n<l; n++) {				presets.addChild(new presetRow());			}		}		function removePresets():void {			if(presets!=null){				panels.panelPresets.removeChild(presets);				//menuRow.clearRows();				presets=null;			}		}		public function handleResize(event:MouseEvent):void {			switch (event.type) {				case MouseEvent.MOUSE_DOWN :					resizer.startDrag(false,new Rectangle(resizer.x,MIN_HEIGHT,0,MAX_HEIGHT));					stage.addEventListener(MouseEvent.MOUSE_MOVE, handleResize);					stage.addEventListener(MouseEvent.MOUSE_UP, handleResize);					break;				case MouseEvent.MOUSE_UP :					resizer.stopDrag();					syncWindowSize();					pixusShell.options.preferencesWindow.height=bg.height=resizer.y;					stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleResize);					stage.removeEventListener(MouseEvent.MOUSE_UP, handleResize);					break;				case MouseEvent.MOUSE_MOVE :					bg.height=resizer.y;					syncWindowSize();					break;			}		}		public function setHeight(h:int){			resizer.y=bg.height=pixusShell.options.preferencesWindow.height=h;			stage.nativeWindow.height = h+100;		}		public function handleMove(event:MouseEvent):void {			switch (event.type) {				case MouseEvent.MOUSE_DOWN :					stage.nativeWindow.startMove();					stage.addEventListener(MouseEvent.MOUSE_UP,handleMove);					break;				case MouseEvent.MOUSE_UP :					stage.removeEventListener(MouseEvent.MOUSE_UP,handleMove);					pixusShell.options.preferencesWindow.x=stage.nativeWindow.x;					pixusShell.options.preferencesWindow.y=stage.nativeWindow.y;					break;			}		}		public function handleTab(event:MouseEvent):void {			switch (event.target) {				case bTabPresets :					tracker.trackPageview('Preferences/Presets');					iconPresets.activate();					panels.slideToPanel(0);					break;				case bTabSkins :					tracker.trackPageview('Preferences/Skins');					iconSkins.activate();					panels.slideToPanel(1);					break;				case bTabOptions :					tracker.trackPageview('Preferences/Options');					iconOptions.activate();					panels.slideToPanel(2);					break;				case bTabHelp :					tracker.trackPageview('Preferences/Help');					iconHelp.activate();					panels.slideToPanel(3);					break;				case bTabAbout :					tracker.trackPageview('Preferences/About');					iconAbout.activate();					panels.slideToPanel(4);					break;			}		}		function syncMenu():void {			NativeApplication.nativeApplication.dispatchEvent(new Event(pixusShell.EVENT_SYNC_MENU));		}		public function handleClose(event:MouseEvent):void {			tracker.trackPageview('Preferences/Hide');			NativeApplication.nativeApplication.dispatchEvent(new customEvent(pixusShell.HIDE_PREFERENCES));		}		public function handleAdd(event:MouseEvent):void {			tracker.trackPageview('Preferences/Presets/Add');			presets.addChild(new presetRow());			panels.panelPresets.dispatchEvent(new customEvent(customEvent.RESIZE));			syncMenu();		}		function get presetListHeight():int{			return bg.height-MARGIN_TOP-MARGIN_BOTTOM;		}		function syncWindowSize():void {			resizer.y=bg.height;			maskPanel.height=bg.height-MARGIN_TOP;			panels.panelPresets.bottomControl.y=panels.panelSkins.bottomControl.y=panels.panelAbout.bottomControl.y=presetListHeight;			panels.panelPresets.dispatchEvent(new customEvent(customEvent.RESIZE,{viewWidth:pixusShell.PREFERENCES_PANEL_WIDTH, viewHeight:presetListHeight}));			panels.panelSkins.dispatchEvent(new customEvent(customEvent.RESIZE,{viewWidth:pixusShell.PREFERENCES_PANEL_WIDTH, viewHeight:presetListHeight}));			panels.panelHelp.dispatchEvent(new customEvent(customEvent.RESIZE,{viewWidth:pixusShell.PREFERENCES_PANEL_WIDTH, viewHeight:resizer.y-MARGIN_TOP-MARGIN_BOTTOM}));			panels.panelOptions.dispatchEvent(new customEvent(customEvent.RESIZE,{viewWidth:pixusShell.PREFERENCES_PANEL_WIDTH, viewHeight:resizer.y-MARGIN_TOP-MARGIN_BOTTOM}));			panels.panelAbout.dispatchEvent(new customEvent(customEvent.RESIZE,{viewWidth:pixusShell.PREFERENCES_PANEL_WIDTH, viewHeight:resizer.y-MARGIN_TOP-MARGIN_BOTTOM}));			stage.nativeWindow.height=bg.height+100;		}	}}