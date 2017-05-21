package
{
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	import flashx.textLayout.formats.BackgroundColor;
	
	/**
	 * This class implements a very simple MP3 player.<br>
	 * This program implements the requirements of the Portfolio Question 4 for the Programming II AS3 Unit.
	 * This code borrows from the SoundPlayPauseStopDemo example provided in the course materials. 
	 * @author Stephen Whitely P308730
	 */
	public class MP3Player extends Sprite
	{
		// embed the mp3
		[Embed(source='assets/Chrono Trigger.mp3')]
		public var MySound:Class;
		
		// a Sound instance from the MySound class (embedded mp3 file)
		private var sound:Sound = new MySound;
		// a SoundChannel instance
		private var channel:SoundChannel;
		// a SoundTransform instance
		private var soundTrans:SoundTransform = new SoundTransform();
		
		private var isPlaying:Boolean = false;
		private var pausePosition:Number = 0;
		
		private var playButton:Sprite;
		private var pauseButton:Sprite;
		private var stopButton:Sprite;
		private var screenWidth:int;
		private var screenHeight:int;
		
		private var stageAnimator:Timer;
		
		private var touchedBackground:Boolean = false;
		private var xDown:int, yDown:int;
		
		public function MP3Player()
		{
			super();
			
			// support autoOrients
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			// get the width and height
			//screenWidth = stage.stageWidth;
			//screenHeight = stage.stageHeight;
			// set the stage background colour
			stage.color = 0x202020;	
			// initialise the buttons as Sprite objects
			playButton = new Sprite();
			pauseButton = new Sprite();
			stopButton = new Sprite();
			// add the buttons to the stage
			addChild(playButton);
			addChild(pauseButton);
			addChild(stopButton);
			// three events share one event handler
			playButton.addEventListener(MouseEvent.MOUSE_DOWN, onButtonTouchDown);
			pauseButton.addEventListener(MouseEvent.MOUSE_DOWN, onButtonTouchDown);
			stopButton.addEventListener(MouseEvent.MOUSE_DOWN, onButtonTouchDown);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onButtonTouchDown);
			// add listener for mouse up
			stage.addEventListener(MouseEvent.MOUSE_UP, onTouchUp);
			// add the timer to draw the stage
			stageAnimator = new Timer(30);
			stageAnimator.start();
			stageAnimator.addEventListener(TimerEvent.TIMER, drawStage);	
			
			// you may note that I haven't set stageWidth and stageHeight in here - that's
			// because they don't return correct values when called in the constructor
		}
		/**
		 * A method to draw the buttons using the graphics objects of each of the button
		 * (Sprite) objects.
		 */
		private function drawButtons():void {
			// set up some colours to use
			var colourPlay:uint;
			var colourPause:uint;
			var colourStop:uint;
			var alpha:Number = 0.75;
			// change colour depending on MP3 player's current state
			if (isPlaying) {
				colourPlay = 0x80F080;
				colourPause = 0xD0D0A0;
				colourStop = 0xD0A0A0;
			} else {
				colourPlay = 0xA0D0A0;
				if (pausePosition == 0) {
					colourPause = 0xD0D0A0;
					colourStop = 0xF08080;
				} else {
					colourPause = 0xF0F080;
					colourStop = 0xD0A0A0;
				}
			}
			// calculate some sizes for the buttons
			var r1:uint = (screenWidth<screenHeight?screenWidth:screenHeight) / 9;
			var r2:uint = r1 * 3 / 4;
			var r3:uint = r1 / 2;
			// play button
			var g:Graphics = playButton.graphics;
			g.clear();
			g.beginFill(colourPlay, alpha);
			g.drawCircle(screenWidth / 4, screenHeight / 2, r1);
			g.beginFill(colourPlay - 0x400040);
			var a:uint = r2 * Math.sin(Math.PI / 6);
			var b:uint = r2 * Math.cos(Math.PI / 6);
			g.moveTo(screenWidth / 4 - a, screenHeight / 2 - b);
			g.lineTo(screenWidth / 4 + r2, screenHeight / 2);
			g.lineTo(screenWidth / 4 - a, screenHeight / 2 + b);
			// pause button
			g = pauseButton.graphics;
			g.clear();
			g.beginFill(colourPause, alpha);
			g.drawCircle(screenWidth / 2, screenHeight / 2, r1);
			g.beginFill(colourPause - 0x000080);
			g.drawRect(screenWidth / 2 - r3, screenHeight / 2 - r3, r3 * 2 / 3, 2 * r3);
			g.drawRect(screenWidth / 2 + r3 / 3, screenHeight / 2 - r3, r3 * 2 / 3, 2 * r3);
			// stop button
			g = stopButton.graphics;
			g.clear();
			g.beginFill(colourStop, alpha);
			g.drawCircle(screenWidth / 4 * 3, screenHeight / 2, r1);
			g.beginFill(colourStop - 0x004040);
			g.drawRect(screenWidth / 4 * 3 - r3, screenHeight / 2 - r3, 2 * r3, 2 * r3);
		}
		/**
		 * The method called when any of the buttons receive a mouse down event.
		 */
		private function onButtonTouchDown(event:MouseEvent):void {
			// determine which button is pressed by comparing object reference
			// play button
			if (event.currentTarget == playButton) {
				if (!isPlaying) {
					playSong();
				}
			// pause button
			} else if (event.currentTarget == pauseButton) {
				if (isPlaying) {
					pausePosition = channel.position;
					stopSong();
				// this lets the pause button resume play if the sound was paused
				} else if (pausePosition != 0) {
					playSong();
				}
			// stop button
			} else if (event.currentTarget == stopButton) {
				if (channel != null) {
					pausePosition = 0;
					stopSong();
				}
			// click on the background? see mouse up event for actions
			} else if (event.currentTarget == stage && (
				// make sure you're outside of the buttons
				event.localY < screenHeight / 2 - screenWidth / 8 ||
				event.localY > screenHeight / 2 + screenWidth / 8)) {
				touchedBackground = true;
				xDown = event.localX;
				yDown = event.localY;
			}
			drawButtons();
		}
		/**
		 * The method called when there is a mouse up event on the stage
		 */
		private function onTouchUp(event:MouseEvent):void {
			// check that the background area was touched in the mouse down event
			if (touchedBackground) {
				// if the user has moved their finger (or mouse) vertically across 
				// the screen, treat it as a volume control
				if (Math.abs(yDown - event.localY) > screenHeight / 8) {
					var volume:Number = soundTrans.volume;
					var step:Number = 0.2
					if (yDown > event.localY) {
						volume += step;
						if (volume > 1) volume = 1;
					} else {
						volume -= step;
						if (volume < 0.1) volume = 0.1;
					}
					soundTrans.volume = volume;
					channel.soundTransform = soundTrans;
				// otherwise seek to position
				} else if (isPlaying) {
					// stop before playing again just to clean up event listeners
					stopSong();
					pausePosition = event.localX / screenWidth * sound.length;
					playSong();
				}
				touchedBackground = false;
			}
		}
		
		/**
		 * A simple helper method to start playing the song.<br>
		 * Also attaches the listener for the sound complete event.
		 */
		private function playSong():void {
			channel = sound.play(pausePosition);
			channel.addEventListener(Event.SOUND_COMPLETE, onSongEnd);
			isPlaying = true;
			stageAnimator.start();
		}
		/**
		 * A simple helper method to stop playing the song.
		 */
		private function stopSong():void {
			// not sure if I have to remove this event listener but I don't want lost 
			// listeners from no-longer referenced objects cluttering up the memory
			channel.removeEventListener(Event.SOUND_COMPLETE, onSongEnd);
			channel.stop();
			isPlaying = false;
			stageAnimator.stop();
		}
		/**
		 * This method is called when sound channel detects a sound complete event. <br>
		 * It resets the playing position and state boolean as well as redrawing the buttons.
		 */
		private function onSongEnd(event:Event):void {
			pausePosition = 0;
			isPlaying = false;
			drawButtons();
		}
		/**
		 * This method is called regularly by an event timer to draw a progress bar across the
		 * background of the app and the peak displays
		 */
		private function drawStage(event:TimerEvent):void {
			// good time to update the width and height
			screenWidth = stage.stageWidth;
			screenHeight = stage.stageHeight;
			graphics.clear();
			// calculate what position in the song we are at
			var complete:Number;
			if (channel == null || (!isPlaying && pausePosition == 0)) {
				complete = 0;
			} else {
				complete = channel.position / sound.length;
			}
			// as the progress bar advances, the colour darkens such that the colour of the progress
			// bar at 100% is the same as the background was at 0%
			stage.color = ((0x200000 * (1 - complete)) & 0xFF0000) + 	// red
				((0x002000 * (1 - complete)) & 0x00FF00) + 				// green
				((0x20 * (1 - complete)) & 0x0000FF);					// blue
			graphics.beginFill(stage.color + 0x202020);
			// draw the progress bar as a rectangle covering a percentage of the screen's background
			graphics.drawRect(0, 0, complete * screenWidth, screenHeight);
			// draw gradient circles from the bottom corners that adjust to the channels peaking levels
			var matrix:Matrix = new Matrix;
			// left
			matrix.createGradientBox(screenWidth*2, screenWidth*2, 0, 0 - screenWidth, screenHeight - screenWidth);
			if (channel != null) {
				graphics.beginGradientFill(GradientType.RADIAL,[0xAAFFAA, 0xCCFFCC], 
					[0.3, 0], [0, 255 * channel.leftPeak], matrix);
				graphics.drawCircle(0, screenHeight, screenWidth);
			}
			// right
			matrix.createGradientBox(screenWidth*2, screenWidth*2, 0, 0, screenHeight - screenWidth);
			if (channel != null) {
				graphics.beginGradientFill(GradientType.RADIAL,[0xAAAAFF, 0xCCCCFF], 
					[0.3, 0], [0, 255 * channel.leftPeak], matrix);
				graphics.drawCircle(screenWidth, screenHeight, screenWidth);
			}
			drawButtons();
		}
	}
}