package org.phpz.app
{
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.HTTPStatusEvent;
    import flash.events.IOErrorEvent;
    import flash.events.MouseEvent;
    import flash.net.navigateToURL;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLRequestHeader;
    import flash.net.URLRequestMethod;
    import flash.net.URLVariables;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.ui.Multitouch;
    import flash.ui.MultitouchInputMode;
	
	/**
	 * ...
	 * @author Seven Yu
	 */
	public class MailYou extends Sprite 
	{
		
        private var access_token:String = '';
        private var debugText:TextField;
        
		public function MailYou():void 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.DEACTIVATE, deactivate);
			
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			// entry point
			
			// new to AIR? please read *carefully* the readme.txt files!
            
            debugText = new TextField();
            debugText.width = stage.stageWidth;
            debugText.height = stage.stageHeight;
            debugText.multiline = true;
            debugText.borderColor = 0;
            debugText.border = true;
            debugText.defaultTextFormat = new TextFormat('consolas');
            addChild(debugText);
            
            var tokenMode:Boolean = true;
            var apiURL:String;
            
            if (tokenMode)
            {
                apiURL = 'https://www.douban.com/service/auth2/token';
            }
            else
            {
                apiURL = 'https://www.douban.com/service/auth2/auth';
            }
            
            var request:URLRequest = new URLRequest(apiURL);
            var uloader:URLLoader = new URLLoader();
            var variables:URLVariables = new URLVariables();
            
            variables.client_id = Test.API_KEY;
            
            if (tokenMode)
            {
                variables.client_secret = Test.SECRET;
                variables.grant_type = 'password';
                variables.username = Test.TEST_USER;
                variables.password = Test.TEST_PASS;
            }
            else
            {
                variables.redirect_uri = 'http://labs.phpz.org/doutest-app/callback.php';
                variables.scope = 'douban_basic_common,shuo_basic_r,shuo_basic_w';
                variables.response_type = 'code'
            }
            
            uloader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            uloader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, statusHandler);
            uloader.addEventListener(Event.COMPLETE, completeHandler);
            
            request.method = URLRequestMethod.POST;
            request.data = variables;
            
            if (tokenMode)
            {
                uloader.load(request);
            }
            else
            {
                navigateToURL(request);
            }
            
            stage.addEventListener(MouseEvent.CLICK, testHandler);
            
		}
        
        private var testIndex:int = 0;
        private function testHandler(e:Event):void 
        {
            debug(access_token); 
            switch(testIndex)
            {
                case 1:
                    api('https://api.douban.com/shuo/v2/statuses/home_timeline');
                    break;
                case 2:
                    api('https://api.douban.com/v2/doumail/inbox');
                    break;
                case 0:
                default:
                    testIndex = 0;
                    api('https://api.douban.com/v2/user/~me');
                    break;
            }
            testIndex++;
        }
        
        private var debugIndex:int = 0;
        private function debug(msg:String):void 
        {
            debugText.appendText('\n--==' + debugIndex++ + ' ==--\n');
            debugText.appendText(msg || 'null');
            trace(msg);
        }
        
        private function ioErrorHandler(e:IOErrorEvent):void 
        {
            debug(e.toString());
        }
        
        private function completeHandler(e:Event):void 
        {
            var result:Object = JSON.parse(e.target.data);
            
            if (result['access_token'])
            {
                debug(e.target.data);
                access_token = result.access_token;
            }
            else
            {
                debug(e.target.data);
            }
        }
        
        private function statusHandler(e:HTTPStatusEvent):void 
        {
            debug([e.type, e.status].join(', '));
        }
        
        private function api(url:String):void
        {
            var req:URLRequest = new URLRequest(url);
            var lder:URLLoader = new URLLoader();
            var vars:URLVariables = new URLVariables();
            
            req.method = URLRequestMethod.GET;
            req.requestHeaders = [new URLRequestHeader('Authorization', 'Bearer ' + access_token)];
            
            req.data = vars;
            
            lder.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, statusHandler);
            lder.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            lder.addEventListener(Event.COMPLETE, completeHandler);
            
            lder.load(req);
        }
		
		private function deactivate(e:Event):void 
		{
			// auto-close
			//NativeApplication.nativeApplication.exit();
		}
		
	}
	
}