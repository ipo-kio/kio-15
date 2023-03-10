/**
 * Created by ilya on 15.02.15.
 */
package ru.ipo.kio._15.spider {

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import ru.ipo.kio.api.KioApi;
import ru.ipo.kio.api.KioProblem;
import ru.ipo.kio.api.controls.GraphicsButton;

import ru.ipo.kio.api.controls.InfoPanel;

import ru.ipo.kio.base.GlobalMetrics;

public class SpiderWorkspace extends Sprite {

    [Embed(source="resources/fon.png")]
    public static const BG:Class;
    public static const BG_IMG:BitmapData = (new BG).bitmapData;

    //----------------------------------------------------------------------

    [Embed(source="resources/kn-1-quesmark.png")]
    public static const HELP_BUTTON_1:Class;
    public static const HELP_BUTTON_1_IMG:BitmapData = (new HELP_BUTTON_1).bitmapData;

    [Embed(source="resources/kn-2-quesmark.png")]
    public static const HELP_BUTTON_2:Class;
    public static const HELP_BUTTON_2_IMG:BitmapData = (new HELP_BUTTON_2).bitmapData;

    [Embed(source="resources/kn-3-quesmark.png")]
    public static const HELP_BUTTON_3:Class;
    public static const HELP_BUTTON_3_IMG:BitmapData = (new HELP_BUTTON_3).bitmapData;

    private var s:Spider;
    private var f:Floor;
    private var m:SpiderMotion;
    private var mt:MechanismTuner;

    private var bigSpider:Spider;

    private var current_info:InfoPanel;
    private var record_info:InfoPanel;

    private var api:KioApi;
    private var problem:KioProblem;

    private var empty_ls:Vector.<Number>;

    public static var MAIN_FONT:String = 'KioArial';

    public function SpiderWorkspace(problem:KioProblem) {
        api = KioApi.instance(problem);
        this.problem = problem;

        if (KioApi.language == KioApi.L_TH)
            MAIN_FONT = 'KioTahoma';

        var mask:Sprite = new Sprite();
        mask.graphics.beginFill(0);
        mask.graphics.drawRect(0, 0, GlobalMetrics.WORKSPACE_WIDTH, GlobalMetrics.WORKSPACE_HEIGHT);
        mask.graphics.endFill();
        addChild(mask);
        mask.visible = false;
        this.mask = mask;

        init_info_panels();

        graphics.beginBitmapFill(BG_IMG);
        graphics.drawRect(0, 0, GlobalMetrics.WORKSPACE_WIDTH, GlobalMetrics.WORKSPACE_HEIGHT);
        graphics.endFill();

        if (stage)
            init();
        else
            addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(e:Event = null):void {
        removeEventListener(Event.ADDED_TO_STAGE, init);

        bigSpider = new Spider(problem.level, 5);

        s = new Spider(problem.level);
        f = new Floor();
        m = new SpiderMotion(this, problem, s, f, bigSpider);

        addChild(m);
        m.x = 0;
        m.y = 500;

        bigSpider.x = GlobalMetrics.WORKSPACE_WIDTH / 2;
        bigSpider.y = 400;
        bigSpider.alpha = 0.3;
        bigSpider.mouseEnabled = false;
        addChild(bigSpider);
        bigSpider.visible = false;

        var tuned_mechanism:Mechanism = new Mechanism(problem.level);
        tuned_mechanism.angle = 0;
        empty_ls = tuned_mechanism.ls;
        mt = new MechanismTuner(problem, tuned_mechanism, m);
        addChild(mt);

        //buttons

        var bigSpiderButton:GraphicsButton = new GraphicsButton('', HELP_BUTTON_1_IMG, HELP_BUTTON_2_IMG, HELP_BUTTON_3_IMG, MAIN_FONT, 24, 24);
        addChild(bigSpiderButton);
        bigSpiderButton.x = 62;
        bigSpiderButton.y = 532;
        bigSpiderButton.addEventListener(MouseEvent.CLICK, function (e:Event):void {
            bigSpider.visible = !bigSpider.visible;
            api.log('big spider visibility = ' + bigSpider.visible);
        });
    }

    private function init_info_panels():void {
        current_info = new InfoPanel(
                MAIN_FONT, true, 16, 0x727272, 0x212121, 0x0086EF, 1.5, api.localization.solution, [
                    api.localization.finished,
                    api.localization.time,
                    api.localization.material
                ],
                210
        );
        addChild(current_info);
        current_info.x = 40;
        current_info.y = 40;

        record_info = new InfoPanel(
                MAIN_FONT, true, 16, 0x727272, 0x212121, 0x0086EF, 1.5, api.localization.record, [
                    api.localization.finished,
                    api.localization.time,
                    api.localization.material
                ],
                210
        );
        addChild(record_info);
        record_info.x = 40;
        record_info.y = 160;

        current_info.setValue(0, '-');
        current_info.setValue(1, '-');
        current_info.setValue(2, '-');
        record_info.setValue(0, '-');
        record_info.setValue(1, '-');
        record_info.setValue(2, '-');
    }

    public function setCurrentResult(result:Object):void {
        setResult(current_info, result);
    }

    public function setRecordResult(result:Object):void {
        setResult(record_info, result);
    }

    public function setResult(info:InfoPanel, result:Object):void {
        function timeToString(t:Number):String {
            if (problem.level == 0)
                return Math.round(t * 10).toFixed(0);
            else
                return t.toFixed(SpiderProblem.ROUND_SECONDS_UP ? 0 : 1);
        }

        if (!result.ok) {
            info.setValue(0, api.localization.no);
            info.setValue(1, result.t == 0 ? '-' : api.localization.longer + ' ' + timeToString(result.t) + ' ' + api.localization.seconds);
        } else {
            info.setValue(0, api.localization.yes);
            info.setValue(1, timeToString(result.t) + ' ' + api.localization.seconds);
        }

        info.setValue(2, result.m + ' ' + api.localization.centimeters);
    }

    public function get solution():Object {
        return {
            ls: vectorToArray(m.ls)
        };
    }

    private static function vectorToArray(ls:Vector.<Number>):Array {
        var res:Array = [];
        for each (var number:Number in ls)
            res.push(number);
        return res;
    }

    public function get result():Object {
        return m.result;
    }

    public function loadSolution(solution:Object):Boolean {
        if (solution == null)
            return false;

        var ls:* = solution.ls;
        if ((ls == null) || !(ls is Array || ls is Vector.<Number>)) {
            trace("failed to load broken solution");
            return false;
        }

        mt.ls = ls is Vector.<Number> ? ls : arrayToVector(ls);
        mt.useSettingButtonHandler();

        return true;
    }

    private static function arrayToVector(ls:Array):Vector.<Number> {
        var res:Vector.<Number> = new <Number>[];
        for each (var i:Number in ls)
            res.push(i);
        return res;
    }

    public function clear():void {
        loadSolution({ls: vectorToArray(empty_ls)});
    }
}
}
