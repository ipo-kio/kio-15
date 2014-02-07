/**
 * Created by user on 06.01.14.
 */
package ru.ipo.kio._14.stars {
import flash.display.Sprite;
import flash.events.MouseEvent;

    public class StarView extends Sprite {

        private static const SELECTED_COLOR:uint = 0xffcc00;
        private static const DEFAULT_COLOR:uint = 0xfcdd76;

        private var _star:Star;
        private var _isSelected:Boolean;

        private var _index:int;

        public function StarView(star:Star) {
            this._star = star;
//            _isSelected = (mouseX >= (star.x - star.radius) && mouseX <= (star.x + star.radius)) && (mouseY >= (star.y - star.radius) && mouseY <= (star.y + star.radius));
            drawDefaultStar();

            addEventListener(MouseEvent.ROLL_OVER, function(e:MouseEvent):void {
                drawSelectedStar();
                _isSelected = true;
            });

            addEventListener(MouseEvent.ROLL_OUT, function(e:MouseEvent):void {
                drawDefaultStar();
                _isSelected = false;
            });

            //make big radius for star to interact with mouse
            addHitArea();
        }

        private function addHitArea():void {
            var hit:Sprite = new Sprite();
            hit.graphics.beginFill(0);
            hit.graphics.drawCircle(_star.x, _star.y, 5);
            hit.graphics.endFill();

            addChild(hit);
            hit.visible = false;

            this.hitArea = hit;
        }

        private function drawDefaultStar():void {
            graphics.clear();
            graphics.beginFill(DEFAULT_COLOR);
            graphics.drawCircle(_star.x, _star.y, _star.radius);
            graphics.endFill();
        }

        private function drawSelectedStar():void {
            graphics.clear();
            graphics.beginFill(SELECTED_COLOR);
            graphics.drawCircle(_star.x, _star.y, _star.radius);
            graphics.endFill();
        }

        public function get index():int {
            return _index;
        }

        public function set index(value:int):void {
            _index = value;
        }

        public function get isSelected():Boolean {
            return _isSelected;
        }
    }
}
