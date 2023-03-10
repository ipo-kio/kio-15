/**
 * Предикат, проверяющий Форму объекта
 *
 * @author: Vasily Akimushkin
 * @since: 21.01.14
 */
package ru.ipo.kio._14.tarski.model.predicates {
import flash.errors.IllegalOperationError;
import flash.utils.Dictionary;

import ru.ipo.kio._14.tarski.model.editor.LogicItem;
import ru.ipo.kio._14.tarski.model.properties.Shapable;
import ru.ipo.kio._14.tarski.model.properties.ShapeValue;
import ru.ipo.kio._14.tarski.model.properties.ValueHolder;

public class ShapePredicate extends OnePlacePredicate{

    /**
     * Проверяемая форма
     */
    private var shape:ShapeValue;
    private var cube:String;
    private var sphere:String;

     public function ShapePredicate(shape:ShapeValue, cube:String, sphere:String) {
        this.shape = shape;
         this.cube=cube;
         this.sphere=sphere;
         super();
    }


    override public function canBeEvaluated():Boolean {
        return formalOperand!=null;
    }

    override public function evaluate(data:Dictionary):Boolean {
        var operand:Shapable=data[formalOperand];
        if(operand==null){
            throw new IllegalOperationError("operand must be not null");
        }
        return shape.code==operand.shape.code;
    }

    public override function toString():String {
        return quantsToSts()+"shape-"+shape.code+"-"+formalOperand+"";
    }

    public function parseString(str:String):ShapePredicate {
        var items:Array = str.split("-");
        shape = ValueHolder.getShape(items[1]);
        if(items[2]!="null"){
            operand = items[2];
            placeHolder.variable = new Variable(formalOperand);
        }
        return this;
    }

    public override function getToolboxText():String {
        return shape.code==ShapeValue.CUBE?cube:sphere;
    }

    public override function getCloned():LogicItem {
        return new ShapePredicate(shape, cube, sphere);
    }
}
}
