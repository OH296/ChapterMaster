// === Multi-mask fragment shader ===
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec2 v_vShadowCoord;

#define MAX_MASKS 32

uniform sampler2D armour_texture;
uniform sampler2D shadow_texture;

uniform vec4 texture_replace_col[MAX_MASKS];
uniform int texture_mask_count;

uniform int use_shadow;
varying vec2 v_vMaskCoord[MAX_MASKS];

// === HSV utilities ===
vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(
        abs(q.z + (q.w - q.y) / (6.0 * d + e)),
        d / (q.x + e),
        q.x
    );
}

vec3 hsv2rgb(vec3 c) {
    vec3 rgb = clamp(
        abs(mod(c.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0,
        0.0,
        1.0
    );
    return c.z * mix(vec3(1.0), rgb, c.y);
}

float hueMixClamp(float fromHue, float toHue, float t, float maxShift) {
    float delta = mod((toHue - fromHue + 540.0), 360.0) - 180.0;
    if (delta > maxShift) delta = maxShift;
    if (delta < -maxShift) delta = -maxShift;
    return mod(fromHue + delta * t, 360.0);
}

vec3 light_or_dark(vec3 m_colour, float shade, float maxHueShift) {
    vec3 hsv = rgb2hsv(m_colour);
    float orig_brightness = max(m_colour.r, max(m_colour.g, m_colour.b));
    bool near_black = (orig_brightness < 0.15);

    if (shade > 1.0) {
        float hue = hsv.x * 360.0;
        if (near_black) {
            hue = hueMixClamp(hue, 180.0, shade - 1.0, 180.0);
            hsv.z = clamp(hsv.z * shade, 0.0, 1.0);
            hsv.y = clamp(hsv.y * (2.0 - shade), 0.0, 1.0);
            hsv.x = hue / 360.0;
        } else {
            hue = hueMixClamp(hue, 60.0, shade - 1.0, maxHueShift);
            hsv.z = clamp(hsv.z * shade, 0.0, 1.0);
            hsv.y = clamp(hsv.y * (2.0 - shade), 0.0, 1.0);
            hsv.x = hue / 360.0;
        }
    } else {
        float hue = hsv.x * 360.0;
        hue = hueMixClamp(hue, 240.0, 1.0 - shade, maxHueShift);
        hsv.x = hue / 360.0;
        hsv.z = clamp(hsv.z * shade, 0.0, 1.0);
        hsv.y = clamp(hsv.y * (1.0 + (1.0 - shade)), 0.0, 1.0);
    }

    vec3 rgb = hsv2rgb(hsv);

    if (!near_black) {
        float maxDelta = 0.05;
        if (m_colour.r < max(m_colour.g, m_colour.b)) rgb.r = min(rgb.r, max(rgb.g, rgb.b) + maxDelta);
        if (m_colour.g < max(m_colour.r, m_colour.b)) rgb.g = min(rgb.g, max(rgb.r, rgb.b) + maxDelta);
        if (m_colour.b < max(m_colour.r, m_colour.g)) rgb.b = min(rgb.b, max(rgb.r, rgb.g) + maxDelta);
    }

    if (near_black && shade > 1.0) {
        float maxRGB = max(rgb.r, max(rgb.g, rgb.b));
        rgb.b = max(rgb.b, maxRGB * 1.1);
    }

    return rgb;
}

// === Main fragment logic ===
void main() {
    const float _60COL = 60.0 / 255.0;
    const float _128COL = 128.0 / 255.0;
    const float _160COL = 160.0 / 255.0;
    const float _215COL = 215.0 / 255.0;

    vec4 base_col = texture2D(gm_BaseTexture, v_vTexcoord);
    if (base_col.a == 0.0) discard;

    bool matched = false;
    vec4 tex_col = vec4(0.0);
    
    for (int i = 0; i < texture_mask_count && i < MAX_MASKS; i++) {
        vec4 rep = texture_replace_col[i];
        if (all(equal(base_col.rgb, rep.rgb))) {
            tex_col = texture2D(armour_texture, v_vMaskCoord[i]);
            if (tex_col.a > 0.0) {
                matched = true;
                break;
            }
        }
    }

    if (!matched) discard;
    vec4 col = tex_col;
    vec4 col_orig = base_col;
    float eps = 0.003;

    // === Shadow / Highlight logic ===
    if (use_shadow != 1) {
        if (abs(col_orig.a - _128COL) < eps) col.rgb = light_or_dark(col.rgb, 1.2, 85.0);
        else if (abs(col_orig.a - _60COL) < eps) col.rgb = light_or_dark(col.rgb, 1.4, 85.0);
        else if (abs(col_orig.a - _215COL) < eps) col.rgb = light_or_dark(col.rgb, 0.6, 85.0);
        else if (abs(col_orig.a - _160COL) < eps) col.rgb = light_or_dark(col.rgb, 0.8, 85.0);
        col.a = 1.0;
    } else {
        vec4 shadow_col = texture2D(shadow_texture, v_vShadowCoord);
        float intensity = shadow_col.r;
        float shadow_factor = 1.0 + (intensity - 0.5);
        col.rgb = light_or_dark(col.rgb, shadow_factor, 85.0);
    }

    gl_FragColor = v_vColour * col;
}
