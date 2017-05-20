package
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
	import flashx.textLayout.formats.BackgroundColor;
	
	/**
	 * This class implements a very simple MP3 player.<br>
	 * This program implements the requirements of the Portfolio Question 4 for the Programming II AS3 Unit.
	 * This code borrows heavily from the SoundPlayPauseStopDemo example provided in the course materials. 
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
		private var isPlaying:Boolean = false;
		private var pausePosition:Number = 0;
		
		private var playButton:Sprite;
		private var pauseButton:Sprite;
		private var stopButton:Sprite;
		private var screenWidth:int;
		private var screenHeight:int;
		
		public function MP3Player()
		{
			super();
			
			// support autoOrients
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			// get the width and height for 
			screenWidth = stage.fullScreenWidth;
			screenHeight = stage.fullScreenHeight;
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
			// draw the buttons
			drawButtons();			
			// three events share one event handler
			playButton.addEventListener(MouseEvent.MOUSE_DOWN, onButtonTouchDown);
			pauseButton.addEventListener(MouseEvent.MOUSE_DOWN, onButtonTouchDown);
			stopButton.addEventListener(MouseEvent.MOUSE_DOWN, onButtonTouchDown);
			
		}
		/**
		 * A function to draw the buttons using the graphics objects of each of the button
		 * (Sprite) objects.
		 */
		private function drawButtons():void {
			// set up some colours to use
			var colourPlay:uint;
			var colourPause:uint;
			var colourStop:uint;
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
			g.beginFill(colourPlay);
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
			g.beginFill(colourPause);
			g.drawCircle(screenWidth / 2, screenHeight / 2, r1);
			g.beginFill(colourPause - 0x000080);
			g.drawRect(screenWidth / 2 - r3, screenHeight / 2 - r3, r3 * 2 / 3, 2 * r3);
			g.drawRect(screenWidth / 2 + r3 / 3, screenHeight / 2 - r3, r3 * 2 / 3, 2 * r3);
			// stop button
			g = stopButton.graphics;
			g.clear();
			g.beginFill(colourStop);
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
			}
			drawButtons();
		}
		/**
		 * A simpler helper function to start playing the song.<br>
		 * Also attaches the listener for the sound complete event.
		 */
		private function playSong():void {
			channel = sound.play(pausePosition);
			channel.addEventListener(Event.SOUND_COMPLETE, onSongEnd);
			isPlaying = true;
		}
		/**
		 * A simple helper function to stop playing the song.
		 */
		private function stopSong():void {
			// not sure if I have to remove this event listener but I don't want lost 
			// listeners from no-longer referenced objects cluttering up the memory
			channel.removeEventListener(Event.SOUND_COMPLETE, onSongEnd);
			channel.stop();
			isPlaying = false;
		}
		/**
		 * This function is called when sound channel detects a sound complete event. <br>
		 * It resets the playing position and state boolean as well as redrawing the buttons.
		 */
		private function onSongEnd(event:Event):void {
			pausePosition = 0;
			isPlaying = false;
			drawButtons();
		}
	}
}