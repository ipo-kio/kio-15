/**
 * Created by user on 06.01.14.
 */
package ru.ipo.kio._14.stars {
//import flash.display.Bitmap;
//import flash.display.BitmapData;
//import flash.display.Loader;
//import flash.display.LoaderInfo;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

//import flash.events.MouseEvent;
//import flash.net.FileFilter;
//import flash.net.FileReference;

import ru.ipo.kio.api.KioApi;
import ru.ipo.kio.api.controls.InfoPanel;

public class StarsWorkspace extends Sprite {

    private var api:KioApi;
    private var level:int;

    private var _sky:StarrySky;
    private var _skyView:StarrySkyView;

    private var infoPanel:InfoPanel;
    private var infoPanelRecord:InfoPanel;

    private var _panel:SkyInfoPanel;

//    private static var fileReference:FileReference;

    [Embed(source='resources/segoepr.ttf', embedAsCFF="false", fontName="Segoe Print", mimeType='application/x-font-truetype')]
    private static var MyFont:Class;

    [Embed(source="resources/bottom.png")]
    private static const BOTTOM:Class;
    private static const BOTTOM_BMP:BitmapData = new BOTTOM().bitmapData;

    private var workspaceLoaded:Boolean = false;

//    [Embed(source="resources/stars_load_example.png")]
//    [Embed(source="resources/example_loading.png")]
//    private static const STARS_LOADING:Class;
//    private static const STARS_LOADING_BMP:BitmapData = new STARS_LOADING().bitmapData;

    public function StarsWorkspace(problem:StarsProblem) {

        graphics.beginFill(0, 1);
        graphics.drawRect(0, 0, 780, 600);
        graphics.endFill();

        //получаем доступ к API, для этого передаем в качестве параметра id нашей задачи
        api = KioApi.instance(problem);
        level = problem.level;

        //button to load a stars image
        var g:Sprite = new Sprite();
        g.graphics.beginFill(0xFFFFFF);
        g.graphics.drawRect(100, 100, 200, 200);
        g.graphics.endFill();
        addChild(g);

//        addEventListener(MouseEvent.MOUSE_MOVE, function (e:MouseEvent):void {
//            trace(e.localX, e.localY);
//        });

        /*g.addEventListener(MouseEvent.CLICK, function(e:Event):void {
            loadStars();
        });*/

        /*var starsArr:Array = [];
        for (var count:int = 0; count <= 60; count++) {

            var x:Number = Math.random()*780;
            var y:Number = Math.random()*480;
            var rad:Number = 1 + Math.random()*3;

            var star:Star = new Star(x, y, rad);

            if (star != null) {
                //test that this star is new

                var len:Boolean = true;

                for each (var s:Star in starsArr) {
                    var dx:Number = star.x - s.x;
                    var dy:Number = star.y - s.y;
                    if (Math.sqrt(dx * dx + dy * dy) <= 20) {
                        len = false;
                        break;
                    } else
                        len = true;
                }

                if (len)
                    starsArr.push(star);
            }
        }*/

        var stars:Array = [new Star(443, 345, 1), new Star(63, 45, 3), new Star(514, 190, 2),
            new Star(70, 140, 2), new Star(238, 45, 1), new Star(163, 50, 3), new Star(103, 98, 1),
            new Star(261, 373, 3), new Star(211, 154, 2), new Star(277, 221, 1), new Star(274, 95, 2),
            new Star(333, 145, 1), new Star(463, 255, 3), new Star(504, 317, 2),
            new Star(390, 245, 2), new Star(443, 65, 1), new Star(593, 60, 3), new Star(143, 148, 1),
            new Star(503, 98, 3), new Star(411, 160, 2), new Star(357, 66, 1), new Star(574, 145, 2),
            new Star(70, 245, 2), new Star(93, 315, 1), new Star(128, 380, 3), new Star(193, 390, 1),
            new Star(93, 198, 3), new Star(171, 241, 2), new Star(194, 299, 1), new Star(374, 345, 2),

            new Star(323, 375, 1), new Star(63, 415, 3), new Star(45, 366, 2), new Star(670, 65, 2),
            new Star(733, 49, 1), new Star(413, 419, 3), new Star(133, 412, 1), new Star(701, 408, 3),
            new Star(611, 400, 2), new Star(677, 326, 1), new Star(634, 195, 2), new Star(555, 245, 1),
            new Star(633, 349, 3), new Star(294, 305, 2), new Star(620, 260, 2), new Star(545, 415, 1),
            new Star(583, 300, 3), new Star(41, 279, 1), new Star(693, 148, 3), new Star(461, 394, 2),
            new Star(657, 416, 1), new Star(699, 225, 2), new Star(540, 345, 2), new Star(353, 408, 1),

            new Star(505, 27, 1), new Star(405, 20, 1), new Star(555, 405, 1), new Star(755, 324, 1),
            new Star(258, 419, 1), new Star(326, 415, 1), new Star(303, 406, 1), new Star(537, 66, 1),
            new Star(232, 18, 1), new Star(28, 95, 1)
        ];

        if (problem.level == 0)
            stars = stars.slice(0, 52);
        if (problem.level == 1)
            stars = stars.slice(0, 58);

        loadWorkspace(stars);
//        loadWorkspace(starsArr);

    }

    public function loadWorkspace(stars:Array):void {
        _sky = new StarrySky(level, stars);
        _skyView = new StarrySkyView(_sky, this);
        addChild(_skyView);

        _sky.addEventListener(Event.CHANGE, sky_changeHandler);
        api.addEventListener(KioApi.RECORD_EVENT, recordChanged);

        _panel = new SkyInfoPanel(_skyView);

        infoPanel = new InfoPanel(
                /*"KioArial", true, //*/"Segoe Print", true,
                15, 0xff0000, 0xffffff, 0xffffff,
                1.5, /*api.localization.result*/"",
                ["", "", "", ""/*api.localization.intersections, api.localization.right_graphs,
                    api.localization.diff_graphs, api.localization.length_of_edges*/], 360
        );

        infoPanelRecord = new InfoPanel(
                /*"KioArial", true, //*/"Segoe Print", true,
                15, 0xff0000, 0xffffff, 0xffffff,
                1.5, /*api.localization.record*/"",
                ["", "", "", ""/*api.localization.intersections, api.localization.right_graphs,
                    api.localization.diff_graphs, api.localization.length_of_edges*/], 360
        );

        infoPanel.setValue(0, "НЕТ");
        infoPanel.setValue(1, "" + 0);
        infoPanel.setValue(2, "" + 0);
        infoPanel.setValue(3, "" + 0 + " св. л.");

        infoPanelRecord.setValue(0, "НЕТ");
        infoPanelRecord.setValue(1, "" + 0);
        infoPanelRecord.setValue(2, "" + 0);
        infoPanelRecord.setValue(3, "" + 0 + " св. л.");

        graphics.beginBitmapFill(BOTTOM_BMP);
        graphics.drawRect(0, 450, 780, 150);
        graphics.endFill();

        _panel.x = 0;
        _panel.y = _skyView.height - 24;
        addChild(_panel);

        addChild(infoPanel);
        addChild(infoPanelRecord);

        infoPanel.x = 0;
        infoPanel.y = 470;
        infoPanelRecord.x = 390;
        infoPanelRecord.y = 470;

        workspaceLoaded = true;
    }

    /*private function loadStars():void {
        fileReference = new FileReference();

        fileReference.addEventListener(Event.SELECT, fileSelected);
        fileReference.browse([new FileFilter("PNG Files (*.png)","*.png"), new FileFilter("PNG Files (*.bmp)","*.bmp")]);
    }

    private function fileSelected(event:Event):void {
        fileReference.addEventListener(Event.COMPLETE, fileLoaded);
        fileReference.load();
    }

    private function fileLoaded(event:Event):void {

        fileReference.removeEventListener(Event.COMPLETE, fileLoaded);

        var loader:Loader = new Loader();

        // ... display the progress bar for converting the image data to a display object ...

        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadBytesHandler);
        loader.loadBytes(fileReference.data);
    }

    private function loadBytesHandler(event:Event):void {
        var loaderInfo:LoaderInfo = (event.target as LoaderInfo);
        loaderInfo.removeEventListener(Event.COMPLETE, loadBytesHandler);

        var BMP:BitmapData = Bitmap(loaderInfo.content).bitmapData;

        var starsArr:Array = [];
        for (var i:int = 0; i < BMP.width; i++) {
            for (var j:int = 0; j < BMP.height; j++) {
                var pixel:uint = BMP.getPixel(i, j);
                var star:Star = null;
                switch (pixel) {
                    case 0x00FF0000:
                        star = new Star(i, j, 3);
                        break;
                    case 0x0000FF00:
                        star = new Star(i, j, 1);
                        break;
                    case 0x000000FF:
                        star = new Star(i, j, 2);
                        break;
                }

                if (star != null) {
                    //test that this star is new

                    var len:Boolean = true;

                    for each (var s:Star in starsArr) {
                        var dx:Number = star.x - s.x;
                        var dy:Number = star.y - s.y;
                        if (Math.sqrt(dx * dx + dy * dy) <= 20) {
                            len = false;
                            break;
                        } else
                            len = true;
                    }

                    if (len)
                        starsArr.push(star);
                }
            }
        }

        loadWorkspace(starsArr);
    }*/

    private function recordChanged(event:Event):void {
        infoPanelRecord.setValue(0, "" + _sky.hasIntersectedAnswer());
        infoPanelRecord.setValue(1, "" + _sky.countOfRightGraphs(level));
        infoPanelRecord.setValue(2, "" + _sky.countDifferentGraphs());
        infoPanelRecord.setValue(3, "" + _sky.sumOfLines.toFixed(3) + " св. л.");
    }

    private function sky_changeHandler(event:Event):void {
        infoPanel.setValue(0, "" + _sky.hasIntersectedAnswer());
        if (_sky.hasIntersectedLines()) {
            infoPanel.setValue(1, "-");
            infoPanel.setValue(2, "-");
            infoPanel.setValue(3, "-");
        } else {
            infoPanel.setValue(1, "" + _sky.countOfRightGraphs(level));
            infoPanel.setValue(2, "" + _sky.countDifferentGraphs());
            infoPanel.setValue(3, "" + _sky.sumOfLines.toFixed(3) + " св. л.");
        }


        api.autoSaveSolution();
        api.submitResult(currentResult());
    }

    public function get solution():Object {
        return {
            lines : _sky.serialize()
        }
    }

    public function currentResult():Object {
        return {
            has_intersected_lines : _sky.hasIntersected(),
            total_number_of_right_graphs : _sky.countOfRightGraphs(level),
            total_number_of_difference_graphs : _sky.countDifferentGraphs(),
            sum_of_lines : _sky.sumOfLines.toFixed(3)
        }
    }

    public function load(solution:Object):Boolean {
        if (!workspaceLoaded)
            return false;

        var starsIndexLines:Array = solution.lines;

        _sky.disable_change_event = true;
        _skyView.clearLines();

        for (var i:int = 0; i < starsIndexLines.length; i++) {
            var s1:Star = _sky.getStarByIndex(starsIndexLines[i][0]);
            var s2:Star = _sky.getStarByIndex(starsIndexLines[i][1]);
            var lineIndex:int = _sky.addLine(s1, s2);

            _skyView.createLineView(s1.x, s1.y);
            _skyView.drawLineView(s2.x, s2.y);
            _skyView.fixLineView(_sky.starsLines[lineIndex]);
        }
        _sky.disable_change_event = false;
        return true;
    }

    public function get skyView():StarrySkyView {
        return _skyView;
    }

    public function get panel():SkyInfoPanel {
        return _panel;
    }
}
}
