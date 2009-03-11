﻿// presetRow class
// (cc)2008 01media jungle
// By Jam Zhang
// jam@01media.cn

package {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.desktop.NativeApplication;
	import flash.net.SharedObject;
	import codeplay.event.customEvent;
	import caurina.transitions.Tweener;

	public class presetRow extends menuRow {

		public function presetRow() {
			super(pixusShell.ROW_WIDTH,pixusShell.PRESET_ROW_HEIGHT,'presetRow');
			addEventListener(Event.ADDED_TO_STAGE, init);

			// Default settings
			if (pixusShell.options.presets[id]==undefined) {
				pixusShell.options.presets[id]={width:pixusShell.options.width,height:pixusShell.options.height,comments:'New Preset'};
			}

		}

		public function init(event:Event):void {
			// HandlesTextFields
			tfWidth.text=pixusShell.options.presets[id].width;
			tfHeight.text=pixusShell.options.presets[id].height;
			tfComments.text=pixusShell.options.presets[id].comments;
			tfWidth.addEventListener(Event.CHANGE, handleChange);
			tfHeight.addEventListener(Event.CHANGE, handleChange);
			tfComments.addEventListener(Event.CHANGE, handleChange);

			syncWindowSize();
			syncMenu();
			hidden.bRemove.addEventListener(MouseEvent.CLICK, handleRemove);
			hidden.bApply.addEventListener(MouseEvent.CLICK, handleApply);
			hidden.bDrag.addEventListener(MouseEvent.MOUSE_DOWN, handleDrag);
		}

		// Handles Preset Changes And Sync Menu
		public function handleChange(event:Event):void {
			switch(event.target){
				case tfWidth:
					pixusShell.options.presets[id].width=int(tfWidth.text);
					break;
				case tfHeight:
					pixusShell.options.presets[id].height=int(tfHeight.text);
					break;
				case tfComments:
					pixusShell.options.presets[id].comments=tfComments.text;
					break;
			}
			syncMenu();
		}

		// Handles Remove Button Click
		public function handleRemove(event:MouseEvent):void {
			switch (event.type) {
				case MouseEvent.CLICK :
					remove();
			}
		}

		// Handles Apply Button Click
		function handleApply(event:Event):void {
			NativeApplication.nativeApplication.dispatchEvent(new customEvent(customEvent.SET_WINDOW_SIZE,pixusShell.options.presets[id]));
		}

		// Handles Mouse Move When Dragging
		public function handleMove(event:MouseEvent):void {
			var n:int;

			switch (event.type) {
				case MouseEvent.MOUSE_MOVE :
					if(currentPosition>id){
						for(n=id+1;n<=currentPosition;n++)
							swap(n);
						id=currentPosition;
					} else if(currentPosition<id){
						for(n=id-1;n>=currentPosition;n--)
							swap(n);
						id=currentPosition;
					}
			}
		}

		// Handles Mouse Up / Down
		public function handleDrag(event:MouseEvent):void {
			switch (event.type) {
				case MouseEvent.MOUSE_DOWN :
					dragging=true;
					stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMove);
					stage.addEventListener(MouseEvent.MOUSE_UP, handleDrag);
					this.startDrag(false,new Rectangle(0,0,0,maxY));
					break;
				case MouseEvent.MOUSE_UP :
					dragging=false;
					stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMove);
					stage.removeEventListener(MouseEvent.MOUSE_UP, handleDrag);
					this.stopDrag();
					syncPosition();
			}
		}

		function syncPosition():void{
			Tweener.addTween(this,{y:currentY,time:pixusShell.UI_TWEENING_TIME,transition:'easeOutCubic'});
		}

		function swap(n:int):void{
			var swappedPreset:Object=pixusShell.options.presets[n];
			pixusShell.options.presets[n]=pixusShell.options.presets[id];
			pixusShell.options.presets[id]=swappedPreset;

			var swappedRow:presetRow=currentRow[n];
			swappedRow.id=id;
			swappedRow.syncPosition();
			currentRow[n]=this;
			currentRow[id]=swappedRow;
			id=n;
			syncMenu();
		}

		function remove():void{
			for(var n=id+1;n<currentRow.length;n++){
				currentRow[n].id--;
				currentRow[n].syncPosition();
				currentRow[n-1]=currentRow[n]
				pixusShell.options.presets[n-1]=pixusShell.options.presets[n];
			}
			currentRow.pop();
			pixusShell.options.presets.pop();
			syncWindowSize();
			syncMenu();
			parent.parent.dispatchEvent(new customEvent(customEvent.CONTENT_RESIZED,{contentHeight:parent.height-pixusShell.PRESET_ROW_HEIGHT}));
			parent.removeChild(this);
			delete this;
		}

		function syncMenu():void{
			NativeApplication.nativeApplication.dispatchEvent(new Event(pixusShell.EVENT_SYNC_MENU));
		}

	}
}