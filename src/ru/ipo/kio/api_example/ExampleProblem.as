package ru.ipo.kio.api_example {
import flash.display.DisplayObject;

import ru.ipo.kio.api.KioApi;
import ru.ipo.kio.api.KioProblem;
import ru.ipo.kio.api.Settings;

/**
 * Пример задачи. Этот файл описывает задачу, он практически не содержит логики работы с задачей, а только выдает информацию по ней для системы.
 * @author Ilya
 */
public class ExampleProblem implements KioProblem {

    //Ссылка на файл с локализацией, в данном случае только русский язык. Если языков больше, необходимо добавить несколько ссылок
    [Embed(source="loc/example.ru.json-settings",mimeType="application/octet-stream")]
    public static var LOCALIZATION_RU:Class;

    //Идентификатор задачи. Строка, используется для ссылки на задачу, необходимо выбрать ее так, чтобы она была короткой, содержала
    //только буквы, цифры и знак дефиса, не совпадала с ID других задач.
    public static const ID:String = "test";

    //Это спрайт, на котором рисуется задача
    private var sp:ExampleProblemSprite;

    private var _level:int;

    //Конструктор задачи. Мы можем сделать его произвольным, API не накладывает на него требований.
    //Будем указывать в конструкторе уровень, чтобы задачу можно было использовать и в
    //конкурсе первого уровня и второго. Если бы она была, например, только для первого уровня, параметр бы
    //был не нужен.
    public function ExampleProblem(level:int) {
        _level = level;

        //в первой строке конструктора задачи требуется вызвать инициализацию api:
        KioApi.initialize(this);

        //Регистрация локализации. Программа должна иметь локализацию для каждого из языков,
        //на котором ее предлагается использовать.
        KioApi.registerLocalization(ID, KioApi.L_RU, new Settings(LOCALIZATION_RU).data);

        //теперь можно писать код конструктора, в частности, создавать объекты, которые используют API:
        //В конструкторе MainSpirte есть вызов API (KioApi.instance(...).localization)
        sp = new ExampleProblemSprite(this);
    }

    /**
     * Произвольный идентификатор задачи, который необходимо выбрать и далее использовать при обращении к api:
     * KioApi.instance(ID).
     */
    public function get id():String {
        return ID;
    }

    /**
     * Год задачи
     */
    public function get year():int {
        return 2014;
    }

    /**
     * Уровень, для которого предназначена задача
     */
    public function get level():int {
        return _level;
    }

    /**
     * Основной объект для отображения, чаще всего это спрайт (Sprite), на котором лежат все элементы
     * задачи. В примере мы его храним в поле объекта
     */
    public function get display():DisplayObject {
        return sp;
    }

    /**
     * В каждый момент времени задача должна уметь вернуть текущее решение, над которым работает участник.
     * Запрос может быть дан в произвольный момент, программа всегда должна быть готова выдать текущее решение.
     */
    public function get solution():Object {
        //в качестве решения возвращаем текст внутри текстового поля задачи
        return {
            txt : sp.text
        };
    }

    /**
     * Функция заставляет программу загрузить решение. На вход она получает одно из тех решений, которое
     * выдала в методе solution(). Другими словами, все выданное в методе solution() сохранятся и иногда отдается
     * обратно в метод loadSolution(). Запрос может быть дан в произвольный момент, программа всегда должна быть
     * готова загрузить новое решение.
     * @param    solution решение для загрузки
     * @return   удалось ли загрузить решение
     */
    public function loadSolution(solution:Object):Boolean {
        //для загрузки решения нужно взять поле txt и записать его в текстовое поле
        if (solution.txt) {
            sp.text = solution.txt;

            //не забыть сохранить решение, как обычно после того как оно изменилось
            KioApi.instance(this).autoSaveSolution();
            //не забыть как обычно после изменения решения пересчитать текущий результат
            KioApi.instance(this).submitResult(sp.currentResult());
            //Если текущий результат еще и показывается где-то на экране, его тоже надо пересчитать
            //TODO это все должно происходить автоматически

            return true;
        } else
            return false;
    }

    /**
     * Проверка решения.
     * Этот метод вызывается только во время проверки, поэтому первоначально его можно не реализовывать. При проверке
     * можно полностью изменять состояние программы.
     * @param    solution решение для проверки
     * @return результат проверки
     */
    public function check(solution:Object):Object {
        loadSolution(solution);
        return sp.currentResult();
    }

    /**
     * Сравнение двух решений. Будем сравнивать так, что чем длинне строка, тем лучше
     * @param    solution1 результат проверки первого решения
     * @param    solution2 результат проверки второго решения
     * @return результат сравнения. Возвращает положительное число, если первое решение лучше, отрицательное, если хуже, и 0, если совпадают
     */
    public function compare(solution1:Object, solution2:Object):int {
        return solution1.length - solution2.length;
    }

    /**
     * Возвращает класс изображения с иконкой. Отображается на экране выбора задачи. При отладке задачи эта картинка все равно не видна,
     * поэтому неважно, что возвращать.
     */
    public function get icon():Class {
        return null;
    }

    /**
     * Возвращает класс изображения с иконкой для экрана помощи по задаче.
     * Отображается на экране с помощью по задаче.
     */
    public function get icon_help():Class {
        return null;
    }

    /**
     * Возвращает класс изображения с иконкой для экрана с условием задачи задаче.
     * Отображается на экране с условием задачи.
     */
    public function get icon_statement():Class {
        return null;
    }

    /**
     * Возвращаем оценку для лучшего решения. Это используется только при проверке, кроме того,
     * скорее всего она будет не нужна в этом году. Поэтому пока реализовывать не нужно.
     */
    public function get best():Object {
        return null;
    }

    public function clear():void {
        //do nothing
    }
}

}