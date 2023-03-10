/**
 * Created by ilya on 18.02.15.
 */
package ru.ipo.kio._15.spider {

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import ru.ipo.kio.api.KioApi;

import ru.ipo.kio.api.KioProblem;

import ru.ipo.kio.api.controls.GraphicsButton;

import ru.ipo.kio.base.GlobalMetrics;

public class MechanismTuner extends Sprite {

    [Embed(source="resources/kn-1-Update.png")]
    public static const USE_SETTINGS_BUTTON_1:Class;
    public static const USE_SETTINGS_BUTTON_1_IMG:BitmapData = (new USE_SETTINGS_BUTTON_1).bitmapData;

    [Embed(source="resources/kn-2-Update.png")]
    public static const USE_SETTINGS_BUTTON_2:Class;
    public static const USE_SETTINGS_BUTTON_2_IMG:BitmapData = (new USE_SETTINGS_BUTTON_2).bitmapData;

    [Embed(source="resources/kn-3-Update.png")]
    public static const USE_SETTINGS_BUTTON_3:Class;
    public static const USE_SETTINGS_BUTTON_3_IMG:BitmapData = (new USE_SETTINGS_BUTTON_3).bitmapData;

    [Embed(source="resources/kn01-1-excmark.png")]
    public static const ERR_BUTTON_1:Class;
    public static const ERR_BUTTON_1_IMG:BitmapData = (new ERR_BUTTON_1).bitmapData;

    [Embed(source="resources/kn01-2-excmark.png")]
    public static const ERR_BUTTON_2:Class;
    public static const ERR_BUTTON_2_IMG:BitmapData = (new ERR_BUTTON_2).bitmapData;

    [Embed(source="resources/kn01-3-excmark.png")]
    public static const ERR_BUTTON_3:Class;
    public static const ERR_BUTTON_3_IMG:BitmapData = (new ERR_BUTTON_3).bitmapData;

    public static const MUL:Number = 4.5;

    private var _m:Mechanism;
    private var _center:Point;

    private var curveLayer:Sprite = new Sprite();

    private var broken:Boolean = false;
    private var animation:Boolean = true;

    private var a_button_on:GraphicsButton;
    private var a_button_off:GraphicsButton;
    private var err_button:GraphicsButton;
    private var err_button_text:Sprite = new Sprite();
    private var useSettingButton:GraphicsButton;
    private var _motion:SpiderMotion;

    private var last_working_ls:Vector.<Number>;

    private var problem:KioProblem;
    private var api:KioApi;

    private var s:Vector.<Stick> = new <Stick>[
        null,
        new Stick(logBack(1)),
        new Stick(logBack(2)),
        new Stick(logBack(3)),
        new Stick(logBack(4)),
        new Stick(logBack(5)),
        new Stick(logBack(6)),
        new Stick(logBack(7))
    ];

    private var _slider:Slider = new Slider(0, 100, 320, 0x212121, 0x212121);

    private var _changingInd:int = -1;

    public function MechanismTuner(problem:KioProblem, m:Mechanism, motion:SpiderMotion) {
        this.problem = problem;
        api = KioApi.instance(problem);
        _m = m;
        _motion = motion;
        last_working_ls = _m.ls;
        _center = _m.p1_p.add(_m.p2_p).add(_m.p3_p);
        _center.setTo(_center.x * MUL / 3, _center.y * MUL / 3);
        _center = _center.add(new Point(0, -30));

        _m.addEventListener(Mechanism.EVENT_ANGLE_CHANGED, function (e:Event):void {
            positionSticks();
        });

        addChild(curveLayer);

        if (problem.level >= 1) {
            //triangle sides
            s.push(new Stick(logBack(8)));
            s.push(new Stick(logBack(9)));
            s.push(new Stick(logBack(10)));

            addChild(s[8]);
            addChild(s[9]);
            addChild(s[10]);
        }

        if (problem.level >= 2) {
            s.push(new Stick(logBack(11)));
            s.push(new Stick(logBack(12)));

            addChild(s[11]);
            addChild(s[12]);
        }

        addChild(s[1]);
        addChild(s[3]);
        addChild(s[6]);
        addChild(s[2]);
        addChild(s[4]);
        addChild(s[5]);
        addChild(s[7]);

        for (var i:int = 1; i < s.length; i++) {
            s[i].addEventListener(Stick.SELECTED_CHANGED_EVENT, function (ind:int):Function {
                return function(e:Event):void {
                    if (!s[ind].selected) {
                        //test nothing is selected
                        for (var jj:int = 1; jj < s.length; jj++)
                            if (s[jj].selected)
                                return;

                        _slider.visible = false;

                        return;
                    }

                    var value:Number = lengthByIndex(ind);
                    _changingInd = ind;

                    var l_from:Number = 3;
                    var l_to:Number = 30;
                    switch (ind) {
                        case 1: l_from = 3; l_to = 16; break;
                        case 2: l_from = 3; l_to = 30; break;
                        case 3: l_from = 3; l_to = 16; break;
                        case 4: l_from = 3; l_to = 30; break;
                        case 5: l_from = 3; l_to = 30; break;
                        case 6: l_from = 3; l_to = 30; break;
                        case 7: l_from = 3; l_to = 32; break;

                        case 8: l_from = 10; l_to = 20; break;
                        case 9: l_from = 10; l_to = 20; break;
                        case 10: l_from = 10; l_to = 20; break;

                        case 11: l_from = -30; l_to = 30; break;
                        case 12: l_from = -30; l_to = 30; break;
                    }

                    _slider.reInit(l_from, l_to, value);
                    _slider.visible = true;

                    for (var j:int = 1; j < s.length; j++)
                        if (j != ind)
                            s[j].selected = false;
                };
            }(i));
        }

        _slider.addEventListener(Slider.VALUE_CHANGED, slider_value_changedHandler);

        positionSticks();

        x = GlobalMetrics.WORKSPACE_WIDTH - 180;
        y = 150;

        _slider.x = -250 + 64;
        _slider.y = -150 + 24;
        _slider.visible = false;
        addChild(_slider);

        drawCurve();

        //place animation button
        //http://stackoverflow.com/questions/22885702/html-for-the-pause-symbol-in-a-video-control
        a_button_on = new GraphicsButton('', SpiderMotion.ANIMATE_BUTTON_ON_1_IMG, SpiderMotion.ANIMATE_BUTTON_ON_2_IMG, SpiderMotion.ANIMATE_BUTTON_ON_3_IMG, 'KioArial', 22, 22, 0, 0, 2, 0);
        a_button_off = new GraphicsButton('', SpiderMotion.ANIMATE_BUTTON_OFF_1_IMG, SpiderMotion.ANIMATE_BUTTON_OFF_2_IMG, SpiderMotion.ANIMATE_BUTTON_OFF_3_IMG, 'KioArial', 12, 12);

        addChild(a_button_on);
        addChild(a_button_off);
        a_button_on.x = -316;
        a_button_on.y = -136;
        a_button_off.x = a_button_on.x;
        a_button_off.y = a_button_on.y;

        a_button_on.visible = false;
        addEventListener(Event.ENTER_FRAME, animate_handler);

        a_button_on.addEventListener(MouseEvent.CLICK, function (e:Event):void {
            if (broken)
                return;
            animation = true;
            turnAnimationOn();
            a_button_on.visible = false;
            a_button_off.visible = true;
            api.log('tuner animation on');
        });

        a_button_off.addEventListener(MouseEvent.CLICK, function (e:Event):void {
            animation = false;
            turnAnimationOff();
            a_button_off.visible = false;
            a_button_on.visible = true;
            api.log('tuner animation off');
        });

        err_button = new GraphicsButton('', ERR_BUTTON_1_IMG, ERR_BUTTON_2_IMG, ERR_BUTTON_3_IMG, 'KioArial', 26, 26);
        err_button.visible = false;
        err_button_text.visible = false;
        err_button.x = 90;
        err_button.y = 200;

        addTextToErrButton();

        err_button.addEventListener(MouseEvent.CLICK, function (e:Event):void {
            ls = last_working_ls;
            api.log('restore from error');
        });

        addChild(err_button);

        useSettingButton = new GraphicsButton(api.localization.apply, USE_SETTINGS_BUTTON_1_IMG, USE_SETTINGS_BUTTON_2_IMG, USE_SETTINGS_BUTTON_3_IMG, SpiderWorkspace.MAIN_FONT, 14, 14, 0, 0, 50, 18, true, 0, true);
        addChild(useSettingButton);
        useSettingButton.x = -316;
        useSettingButton.y = -90;
        useSettingButton.addEventListener(MouseEvent.CLICK, useSettingButtonHandler);
    }

    public function useSettingButtonHandler(e:Event = null):void {
        if (_m.broken)
            return; //TODO disable if broken
        _motion.ls = _m.ls;
        _motion.reset();
        api.autoSaveSolution();
        api.log('apply');
    }

    private function addTextToErrButton():void {
        var x0:Number = err_button.width / 2 - 2 + err_button.x;
        var y0:Number = err_button.height / 2 + err_button.y;

        var textFormat:TextFormat = new TextFormat(SpiderWorkspace.MAIN_FONT, 14, 0xE30C0C, true);
        var t1:TextField = new TextField();
        t1.defaultTextFormat = textFormat;
        t1.embedFonts = true;
        t1.width = 0;
        t1.autoSize = TextFieldAutoSize.CENTER;
        t1.x = x0;
        t1.y = y0 - 23 - Number(textFormat.size) - 4;
        t1.mouseEnabled = false;

        var t2:TextField = new TextField();
        t2.defaultTextFormat = textFormat;
        t2.embedFonts = true;
        t2.width = 0;
        t2.autoSize = TextFieldAutoSize.CENTER;
        t2.x = x0;
        t2.y = y0 + 23;

        err_button_text.addChild(t1);
        err_button_text.addChild(t2);
        addChild(err_button_text);
        t2.mouseEnabled = false;

        t1.text = api.localization.broken;
        t2.text = api.localization.repair;
    }

    public function set ls(value:Vector.<Number>):void {
        _m.ls = value;
        if (animation)
            turnAnimationOn();
        positionSticks();
        err_button.visible = false;
        err_button_text.visible = false;
        drawCurve();

        if (_changingInd >= 0)
            _slider.value = lengthByIndex(_changingInd);
    }

    private var __tick:int = 0;
    private function animate_handler(e:Event):void {
        if (__tick++ % 3 != 0)
            return;
        _m.angle += 0.1;
    }

    private function turnAnimationOff():void {
        removeEventListener(Event.ENTER_FRAME, animate_handler);
    }

    private function turnAnimationOn():void {
        addEventListener(Event.ENTER_FRAME, animate_handler);
    }

    private function positionStick(s:Stick, p1:Point, p2:Point):void {
        s.setCoordinates(p1.x * MUL - _center.x, p1.y * MUL - _center.y, p2.x * MUL - _center.x, p2.y * MUL - _center.y);
    }

    private function positionSticks():void {
        //draw triangle
        graphics.clear();
        graphics.lineStyle(2, 0x7EC4F3);
        graphics.beginFill(0xE0F1FC);
        graphics.drawTriangles(new <Number>[
            _m.p1_p.x * MUL - _center.x,
            _m.p1_p.y * MUL - _center.y,
            _m.p2_p.x * MUL - _center.x,
            _m.p2_p.y * MUL - _center.y,
            _m.p3_p.x * MUL - _center.x,
            _m.p3_p.y * MUL - _center.y
        ]);
        graphics.endFill();

        //s[1] is always visible
        for (var i:int = 2; i < s.length; i++)
            s[i].visible = !_m.broken;
        s[2].visible ||= _m.brokenStep == 2;
        s[3].visible ||= _m.brokenStep == 2;
        s[4].visible ||= _m.brokenStep == 2;
        //TODO visibility for step0

        positionStick(s[1], _m.p1_p, _m.m_p);
        positionStick(s[2], _m.m_p, _m.n_p);
        positionStick(s[3], _m.n_p, _m.p2_p);
        positionStick(s[4], _m.n_p, _m.k_p);
        positionStick(s[5], _m.l_p, _m.k_p);
        positionStick(s[6], _m.p3_p, _m.l_p);
        positionStick(s[7], _m.k_p, _m.s_p);

        if (problem.level >= 1) {
            positionStick(s[8], _m.p2_p, _m.p3_p);
            positionStick(s[9], _m.p1_p, _m.p3_p);
            positionStick(s[10], _m.p1_p, _m.p2_p);
        }

        if (problem.level >= 2) {
            positionStick(s[11], _m.p2_p.add(new Point(40, 0)), _m.p2_p.add(new Point(40, -5)));
            positionStick(s[12], _m.p2_p.add(new Point(36, 0)), _m.p2_p.add(new Point(36, -5)));
        }
    }

    private function slider_value_changedHandler(event:Event = null):void {
        switch (_changingInd) {
            case 1:
                _m.l1 = Math.round(_slider.value);
                break;
            case 2:
                _m.l2 = Math.round(_slider.value);
                break;
            case 3:
                _m.l3 = Math.round(_slider.value);
                break;
            case 4:
                _m.l4 = Math.round(_slider.value);
                break;
            case 5:
                _m.l5 = Math.round(_slider.value);
                break;
            case 6:
                _m.l6 = Math.round(_slider.value);
                break;
            case 7:
                _m.l7 = Math.round(_slider.value);
                break;

            case 8:
                _m.ll1 = Math.round(_slider.value);
                break;
            case 9:
                _m.ll2 = Math.round(_slider.value);
                break;
            case 10:
                _m.ll3 = Math.round(_slider.value);
                break;

            case 11:
                _m.a1 = Mechanism.grad2rad(Math.round(_slider.value));
                break;
            case 12:
                _m.a2 = Mechanism.grad2rad(Math.round(_slider.value));
                break;
        }

        var broken:Boolean = drawCurve();

        if (broken) {
            this.broken = true;
            //rotate until not broken
            var ind:int = -1;
            var curve:Vector.<Point> = _m.curve(100);
            for (var i:int = 0; i < curve.length; i++)
                if (curve[i] != null) {
                    ind = i;
                    break;
                }
            if (ind != -1) {
                var a:Number = Math.PI * 2 * ind / curve.length;
                _m.angle = a;
                positionSticks();
            }
            turnAnimationOff();
            err_button.visible = true;
            err_button_text.visible = true;
            useSettingButton.visible = false;
        } else {
            this.broken = false;
            if (animation)
                turnAnimationOn();
            positionSticks();
            last_working_ls = _m.ls;
            err_button.visible = false;
            err_button_text.visible = false;
            useSettingButton.visible = true;
        }
    }

    private function lengthByIndex(ind:int):Number {
        switch (ind) {
            case 1:
                return _m.l1;
            case 2:
                return _m.l2;
            case 3:
                return _m.l3;
            case 4:
                return _m.l4;
            case 5:
                return _m.l5;
            case 6:
                return _m.l6;
            case 7:
                return _m.l7;
            case 8:
                return _m.ll1;
            case 9:
                return _m.ll2;
            case 10:
                return _m.ll3;
            case 11:
                return Mechanism.rad2grad(_m.a1);
            case 12:
                return Mechanism.rad2grad(_m.a2);
        }
        return NaN;
    }

    private function drawCurve():Boolean {
        var curve:Vector.<Point> = _m.curve(100);
        var g:Graphics = curveLayer.graphics;
        g.clear();
        g.lineStyle(0.5, 0xE80BE5);

        var broken:Boolean = false;

        for (var i:int = 0; i < curve.length; i++) {
            var j:int = i - 1;
            if (j < 0)
                j = curve.length - 1;

            var p1:Point = curve[j];
            var p2:Point = curve[i];

            if (p1 == null || p2 == null) {
                broken = true;
                continue;
            }
            g.moveTo(p1.x * MUL - _center.x, p1.y * MUL - _center.y);
            g.lineTo(p2.x * MUL - _center.x, p2.y * MUL - _center.y);
        }

        return broken;
    }

    private function logBack(ind:int):Function {
        return function():void {
            api.log('click on stick ' + ind);
        }
    }
}
}
