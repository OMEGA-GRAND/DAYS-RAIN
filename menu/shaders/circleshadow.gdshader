shader_type canvas_item;

uniform float value : hint_range(0.01, 1);
void fragment() {
    // Расчет расстояния от центра до текущего пикселя
    vec2 center = vec2(0.5, 0.5); // Центр экрана
    float dist = distance(UV, center);
    
    // Применение радиального градиента
    float alpha = smoothstep(0.05, 0.8, dist); // Значения 0.6 и 0.7 определяют зону перехода
    
    // Установка цвета с альфа-каналом
    COLOR = vec4(vec3(0.0), alpha  * value); // Чёрный цвет с изменяющейся прозрачностью
}