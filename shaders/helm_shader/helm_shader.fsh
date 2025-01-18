//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec3 replace_colour;
uniform sampler2D background_texture;

void main()
{
	vec4 col = texture2D(gm_BaseTexture, v_vTexcoord);
   if (col.rgb == vec3(0.0,0.0, 128.0/255.0).rgb){
     col.rgb = replace_colour.rgb;
   };	
   if (col.rgb == vec3(0.0,0.0, 1.0).rgb){
         col.rgb = replace_colour.rgb;
    };
     if (col.rgb == vec3(128.0/255.0,64.0/255.0, 1.0).rgb){
         col.rgb = replace_colour.rgb;
    };
     if (col.rgb == vec3(64.0/255.0,128.0/255.0, 1.0).rgb){
         col.rgb = replace_colour.rgb;
    };	
    gl_FragColor = v_vColour * col;
}
