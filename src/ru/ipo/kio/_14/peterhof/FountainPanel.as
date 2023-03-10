/**
 * Created by ilya on 31.01.14.
 */
package ru.ipo.kio._14.peterhof {
import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import ru.ipo.kio._14.peterhof.model.Consts;

import ru.ipo.kio._14.peterhof.model.Fountain;
import ru.ipo.kio._14.peterhof.view.Sprayer;
import ru.ipo.kio.api.KioApi;

public class FountainPanel extends Sprite {

    private var _fountain:Fountain = null;

    private var _alphaEditor:NumberEditor;
    private var _phiEditor:NumberEditor;
    private var _sprayerWidthEditor:NumberEditor;
    private var _sprayerLengthEditor:NumberEditor;

    private var _streamLengthInfo:TextField;

    private var _sprayer:Sprayer;

    private var _api:KioApi;
    private var _loc:Object;
    private var _showSprayer:Boolean;

    public function FountainPanel(width:int, api:KioApi, showSprayer:Boolean) {
        _api = api;
        _loc = api.localization;
        _showSprayer = showSprayer;

        const skip:int = 206;

        _alphaEditor = new NumberEditor(width, 18, 0, 90, 45, "°", 0, "alpha");
        var alphaEditor:TitledObject = new TitledObject(_loc.f_tilt, 24, 0x000000, _alphaEditor, skip);
        addChild(alphaEditor);

        _phiEditor = new NumberEditor(width, 18, -180, 180, 0, "°", 0, "phi");
        var phiEditor:TitledObject = new TitledObject(_loc.f_rotation, 24, 0x000000, _phiEditor, skip);
        addChild(phiEditor);
        phiEditor.y = alphaEditor.height - 4;

        _sprayerWidthEditor = new NumberEditor(width, 18, 0.1, 5, 0.1, _loc.centimeters, 1, "diam");
        var sprayerWidthEditor:TitledObject = new TitledObject(showSprayer ? _loc.f_diameter : "", 24, 0x000000, _sprayerWidthEditor, skip);
        addChild(sprayerWidthEditor);
        sprayerWidthEditor.y = phiEditor.y + phiEditor.height - 4;

        _sprayerLengthEditor = new NumberEditor(width, 18, 5, 10, 5, _loc.centimeters, 1, "len");
        var sprayerLengthEditor:TitledObject = new TitledObject(showSprayer ? _loc.f_length : "", 24, 0x000000, _sprayerLengthEditor, skip);
        addChild(sprayerLengthEditor);
        sprayerLengthEditor.y = sprayerWidthEditor.y + sprayerWidthEditor.height - 4;

        _streamLengthInfo = new TextField();
        _streamLengthInfo.selectable = false;
        _streamLengthInfo.defaultTextFormat = new TextFormat("KioTahoma", 18, 0x000000);
        _streamLengthInfo.autoSize = TextFieldAutoSize.LEFT;
        _streamLengthInfo.multiline = true;
        _streamLengthInfo.x = sprayerWidthEditor.x + sprayerWidthEditor.width + 12;
        _streamLengthInfo.y = 14;

        _alphaEditor.addEventListener(Event.CHANGE, alphaEditor_changeHandler);
        _phiEditor.addEventListener(Event.CHANGE, phiEditor_changeHandler);
        _sprayerWidthEditor.addEventListener(Event.CHANGE, sprayerWidthEditor_changeHandler);
        _sprayerLengthEditor.addEventListener(Event.CHANGE, sprayerLengthEditor_changeHandler);

        //setup sprayer
        _sprayer = new Sprayer(Consts.D, 60);
        addChild(_sprayer);
        addChild(_streamLengthInfo);

        _sprayer.x = _streamLengthInfo.x + 8;
        _sprayer.y = 64;

        //hide all initially
        _alphaEditor.visible = false;
        _phiEditor.visible = false;
        _sprayerWidthEditor.visible = false;
        _sprayerLengthEditor.visible = false;
        _streamLengthInfo.visible = false;
        _sprayer.visible = false;
    }


    public function get fountain():Fountain {
        return _fountain;
    }

    public function set fountain(value:Fountain):void {
        if (_fountain != null)
            _fountain.removeEventListener(Event.CHANGE, fountainChangeHandler);

        _fountain = value;

        if (_fountain != null)
            _fountain.addEventListener(Event.CHANGE, fountainChangeHandler);

        var show:Boolean = _fountain != null;

        _alphaEditor.visible = show;
        _phiEditor.visible = show;
        _sprayerWidthEditor.visible = show && _showSprayer;
        _sprayerLengthEditor.visible = show && _showSprayer;
        _streamLengthInfo.visible = show;
        _sprayer.visible = show;

        fountainChangeHandler(null);
    }

    private function fountainChangeHandler(event:Event):void {
        _alphaEditor.value = _fountain.alphaGr;
        _phiEditor.value = _fountain.phiGr;
        _sprayerWidthEditor.value = _fountain.d * 100;
        _sprayerLengthEditor.value = _fountain.l * 100;

        _streamLengthInfo.text = _fountain.stream.goes_out ?
                _loc.stream_header + "\n" + _loc.stream_out :
                _loc.stream_header + "\n" + _fountain.stream.length.toFixed(3) + ' ' + _loc.meters;

        if (_fountain != null) {
            _sprayer.f_length = _fountain.l;
            _sprayer.f_width = _fountain.d;
            _sprayer.rotate(_fountain.alphaGr * Math.PI / 180);
        }
    }

    private function alphaEditor_changeHandler(event:Event):void {
        if (_fountain != null && !_alphaEditor.has_error()) {
            _fountain.alphaGr = _alphaEditor.value;
            _sprayer.rotate(_alphaEditor.value * Math.PI / 180);
            _api.autoSaveSolution();
        }
    }

    private function phiEditor_changeHandler(event:Event):void {
        if (_fountain != null && !_phiEditor.has_error()) {
            _fountain.phiGr = _phiEditor.value;
            _api.autoSaveSolution();
        }
    }

    private function sprayerWidthEditor_changeHandler(event:Event):void {
        if (_fountain != null && !_sprayerWidthEditor.has_error()) {
            var newValue:Number = _sprayerWidthEditor.value / 100;

            _sprayer.f_width = newValue;
            _fountain.d = newValue;
            _api.autoSaveSolution();
        }
    }

    private function sprayerLengthEditor_changeHandler(event:Event):void {
        if (_fountain != null && !_sprayerLengthEditor.has_error()) {
            var newValue:Number = _sprayerLengthEditor.value / 100;

            _sprayer.f_length = newValue;
            _fountain.l = newValue;
            _api.autoSaveSolution();
        }
    }
}
}
