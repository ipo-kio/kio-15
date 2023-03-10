/**
 * @author: Vasily Akimushkin
 * @since: 24.02.14
 */
package ru.ipo.kio._14.tarski.utils {
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;

public class FormUtils {
    private static const DEFAULT_INPUT_HEIFGHT:int=20;

    public static function createLabel(text:String,x:int,y:int,height:int=DEFAULT_INPUT_HEIFGHT, bold:Boolean = false){
        var field:TextField = new TextField();
        field.text=text;
        field.selectable=false;
        field.border=false;
        field.type=TextFieldType.DYNAMIC;
        field.x=x;
        field.y=y;
        field.height=height;
        var format:TextFormat = new TextFormat("Arial", 14, 0x000000, bold);
        field.setTextFormat(format);
        field.width=field.textWidth+30;
        field.defaultTextFormat=format;
        return field;
    }

    public static function createInput(x:int,y:int,height:int=DEFAULT_INPUT_HEIFGHT, size:int=12){
        var field:TextField = new TextField();
        var format:TextFormat = new TextFormat("Arial", size);
        field.defaultTextFormat=format;
        field.selectable=false;
        field.border=true;
        field.type=TextFieldType.INPUT;
        field.x=x;
        field.y=y;
        field.height=height;
        return field;
    }
}
}
