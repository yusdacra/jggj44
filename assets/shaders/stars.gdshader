shader_type canvas_item;

uniform sampler2D screen_texture:hint_screen_texture,repeat_disable,filter_nearest;
uniform float startstars = 0.5; //minimum brightness from which stars fade in
uniform float brightnessmax = 0.8; //until which point the stars fade in, after which they’re 100% visible
uniform sampler2D starmap:repeat_enable; //import star texture image

uniform float speed = 0.02; //star movement speed
uniform float scale = 1.; //star texture scale
uniform float intensity = 2.; //star brightness

void fragment() {
    vec4 color = texture(screen_texture,SCREEN_UV);
    float grayscale_value = dot(color.rgb, vec3(0.299, 0.587, 0.114));

    vec2 screenpos = SCREEN_UV/SCREEN_PIXEL_SIZE * SCREEN_PIXEL_SIZE.y /(scale)  + TIME*speed;
    float effectfactor = clamp( (  (1.0-grayscale_value-startstars) * (1.0/(brightnessmax-startstars))  ), 0.,1. ); //get opacity at which stars overlay
    color.rgb += intensity * vec3(texture(starmap, screenpos).a) * effectfactor; //overlay stars

//    Apply color
    COLOR = color;
}