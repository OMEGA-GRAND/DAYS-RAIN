shader_type canvas_item;

uniform float value : hint_range(0.01, 1) = 1;
void fragment() {
    // Расчет расстояния от центра до текущего пикселя
    vec2 center = vec2(0.5, 0.5); // Центр экрана
    float dist = distance(UV, center);
    
    // Применение радиального градиента
    float alpha = smoothstep(0.01, 0.5, dist); // Значения 0.01 и 0.5 определяют зону перехода, то-есть пределы степени затемнения
    
    // Установка цвета с альфа-каналом
    COLOR = vec4(vec3(0.0), alpha  * value); // Чёрный цвет с изменяющейся прозрачностью
}