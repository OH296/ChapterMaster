// === Multi-mask vertex shader ===
attribute vec3 in_Position;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define MAX_MASKS 32

uniform vec4 mask_transform[MAX_MASKS];
uniform int texture_mask_count;

uniform vec4 In_Shadow_Transform;
varying vec2 v_vShadowCoord;
varying vec2 v_vMaskCoord[MAX_MASKS];

void main()
{
    vec4 object_space_pos = vec4(in_Position.xyz, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;

    v_vTexcoord = in_TextureCoord;
    v_vColour = in_Colour;

    for (int i = 0; i < texture_mask_count; i++) {
        v_vMaskCoord[i] = in_TextureCoord * mask_transform[i].zw + mask_transform[i].xy;
    }

    v_vShadowCoord = in_TextureCoord * In_Shadow_Transform.zw + In_Shadow_Transform.xy;
}
