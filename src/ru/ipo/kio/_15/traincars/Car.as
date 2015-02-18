/**
 * Created by ilya on 31.01.15.
 */
package ru.ipo.kio._15.traincars {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

public class Car extends Sprite {

    [Embed(source="resources/01-vagon.png")]
    public static const CAR_1_CLASS:Class;
    public static const CAR_1_IMG:BitmapData = (new CAR_1_CLASS).bitmapData;
    [Embed(source="resources/02-vagon.png")]
    public static const CAR_2_CLASS:Class;
    public static const CAR_2_IMG:BitmapData = (new CAR_2_CLASS).bitmapData;
    [Embed(source="resources/03-vagon.png")]
    public static const CAR_3_CLASS:Class;
    public static const CAR_3_IMG:BitmapData = (new CAR_3_CLASS).bitmapData;
    [Embed(source="resources/04-vagon.png")]
    public static const CAR_4_CLASS:Class;
    public static const CAR_4_IMG:BitmapData = (new CAR_4_CLASS).bitmapData;

    [Embed(source="resources/00-lokomotiv.png")]
    public static const LOCO_CLASS:Class;
    public static const LOCO_IMG:BitmapData = (new LOCO_CLASS).bitmapData;

    public static const LENGTH:Number = 32;
    public static const WIDTH:Number = 14;
//    public static const STATION_COLOR:Vector.<uint> = new <uint>[0x88FFFF, 0xFF88FF, 0xFFFF88, 0x88FF88, 0x888888];
    public static const STATION_COLOR:Vector.<BitmapData> = new <BitmapData>[CAR_1_IMG, CAR_2_IMG, CAR_3_IMG, CAR_4_IMG, LOCO_IMG];
    public static const TEXT_COLOR:uint = 0x000000;
    public static const NUMBER_HEIGHT:Number = 12;
    public static const CAR_TICKS_LENGTH:int = Math.ceil(LENGTH / CurveRail.DL) + 2;

    public static const MOVING_STOP:int = 0;
    public static const MOVING_FORWARD:int = 1;
    public static const MOVING_BACKWARDS:int = 2;

    public static const EVENT_PUSH_DOWN:String = 'push down';
    public static const EVENT_PUSH_UP:String = 'push up';
    public static const EVENT_START_MOVE:String = 'start move';
    public static const EVENT_STOP_MOVE:String = 'stop move';

    public static const DT_SPEED:int = 2;

    private var _station:int;
    private var _number:int;

    private var _tick:int;

    private var numberView:TextField;
    private var numberHeight:Number;

    private var _moveDelta:int = 0;
    private var _moving:Boolean = false;
    private var _movingWay:RailWay;

    public function Car(station:int, number:int) {
        _station = station;
        _number = number;

        var CUR_IMG:BitmapData = STATION_COLOR[station];

        var dx_1:Number = this.x - (CUR_IMG.width*0.5);
        var dy_1:Number = this.y - (CUR_IMG.height*0.5);

        var m:Matrix = new Matrix();
        m.translate(dx_1, dy_1);

//        graphics.lineStyle(0.5, 0);
//        graphics.beginFill(STATION_COLOR[station]);
        graphics.beginBitmapFill(CUR_IMG);
        //noinspection JSSuspiciousNameCombination
//        graphics.drawRect(-LENGTH / 2, -WIDTH / 2, LENGTH, WIDTH);
        graphics.drawRect((-LENGTH / 2) + 3, (-WIDTH / 2) + 3, CUR_IMG.width, CUR_IMG.height);
        graphics.endFill();

        initNumberView();
    }

    public function get station():int {
        return _station;
    }

    public function get number():int {
        return _number;
    }

    public function get tick():int {
        return _tick;
    }

    private function initNumberView():void {
        numberView = new TextField();

        if (_number <= 0)
            return;

        numberView.defaultTextFormat = new TextFormat('KioArial', NUMBER_HEIGHT, TEXT_COLOR, true);
        numberView.embedFonts = true;
        numberView.text = '';

        numberView.width = 0;
        numberView.height = 0;

        numberView.autoSize = TextFieldAutoSize.CENTER;
        numberView.text = '' + _number;

        numberView.y = -numberView.height / 2;
        numberView.x = -numberView.width / 2;

        addChild(numberView);

        numberHeight = numberView.height;
    }

    public function moveTo(way:RailWay, tick:int):Boolean {
        var rail:CurveRail = null;
        for (var railInd:int = way.size - 1; railInd >= 0; railInd--) {
            rail = way.rail(railInd);
            if (rail.startK <= tick)
                break;
        }

        if (rail == null) // do nothing if can not move
            return false;

        var t:Number = rail.parametrizeByTick(tick);
        if (t < 0) // again, do nothing if failed to find position to move
            return false;

        var point:Point = rail.parametrize(t);

        var diff:Point = rail.parametrizeDiff(t);

        var m:Matrix = new Matrix();
        m.rotate(Math.atan2(diff.y, diff.x));
        m.translate(point.x, point.y);

        transform.matrix = m;

        var mt:Matrix = new Matrix();
        mt.translate(0, -numberHeight / 2);
        mt.rotate(-Math.atan2(diff.y, diff.x));

        numberView.transform.matrix = mt;

        _tick = tick;
        return true;
    }

    public override function toString():String {
        return "[" + String(_station) + "," + String(_number) + "]";
    }

    public function addMoveDelta(delta:int, movingWay:RailWay):void {
        if (_moveDelta == 0)
            dispatchEvent(new Event(EVENT_START_MOVE));

        if (_moveDelta < 0)
            return;

        _moveDelta += delta;
        _movingWay = movingWay;

        initListener();
    }

    public function subMoveDelta(delta:int, movingWay:RailWay):void {
        if (_moveDelta == 0)
            dispatchEvent(new Event(EVENT_START_MOVE));

        if (_moveDelta > 0)
            return;

        _moveDelta -= delta;
        _movingWay = movingWay;

        initListener();
    }

    private function initListener():void {
        if (_moving)
            return;
        _moving = true;
        addEventListener(Event.ENTER_FRAME, doMove);
    }

    private function doMove(e:Event):void {
        var dt:int = Math.min(Math.abs(_moveDelta), DT_SPEED);

        if (_moveDelta > 0) {
            _moveDelta -= dt;
            moveTo(_movingWay, tick + dt);
            if (_moveDelta <= 0) {
                _moveDelta = 0;
                stopMovement();
            }

            if (tick >= TrainCarsWorkspace.WAY_START_TICK - CAR_TICKS_LENGTH)
                dispatchEvent(new Event(EVENT_PUSH_DOWN));
        }
        if (_moveDelta < 0) {
            _moveDelta += dt;
            moveTo(_movingWay, tick - dt);
            if (_moveDelta >= 0) {
                _moveDelta = 0;
                stopMovement();
            }

            if (tick <= TrainCarsWorkspace.TOP_END_TICK + CAR_TICKS_LENGTH)
                dispatchEvent(new Event(EVENT_PUSH_UP));
        }

    }

    public function get moving():int {
        if (!_moving || _moveDelta == 0)
            return MOVING_STOP;
        if (_moveDelta < 0)
            return MOVING_BACKWARDS;
        else
            return MOVING_FORWARD;
    }

    public function isMoving():Boolean {
        return moving != MOVING_STOP;
    }

    public function get way():RailWay {
        return _movingWay;
    }

    public function stopMovement():void {
        _moving = false;
        _moveDelta = 0;
        removeEventListener(Event.ENTER_FRAME, doMove);
        dispatchEvent(new Event(EVENT_STOP_MOVE));
    }
}
}
