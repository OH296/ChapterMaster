uniform vec3 left_leg_lower;
uniform int  left_leg_lower_shine;

uniform vec3 left_leg_upper;
uniform int  left_leg_upper_shine;

uniform vec3 left_leg_knee;
uniform int  left_leg_knee_shine;

uniform vec3 right_leg_lower;
uniform int  right_leg_lower_shine;

uniform vec3 right_leg_upper;
uniform int  right_leg_upper_shine;

uniform vec3 right_leg_knee;
uniform int  right_leg_knee_shine;

uniform vec3 metallic_trim;
uniform int  metallic_trim_shine;

uniform vec3 right_trim;
uniform int  right_trim_shine;

uniform vec3 left_trim;
uniform int  left_trim_shine;

uniform vec3 left_chest;
uniform int  left_chest_shine;

uniform vec3 main_colour;
uniform int  main_colour_shine;

uniform vec3 right_chest;
uniform int  right_chest_shine;

uniform vec3 left_thorax;
uniform int  left_thorax_shine;

uniform vec3 right_thorax;
uniform int  right_thorax_shine;

uniform vec3 left_pauldron;
uniform int  left_pauldron_shine;

uniform vec3 right_pauldron;
uniform int  right_pauldron_shine;

uniform vec3 left_head;
uniform int  left_head_shine;

uniform vec3 right_head;
uniform int  right_head_shine;

uniform vec3 left_muzzle;
uniform int  left_muzzle_shine;

uniform vec3 right_muzzle;
uniform int  right_muzzle_shine;

uniform vec3 left_arm;
uniform int  left_arm_shine;

uniform vec3 right_arm;
uniform int  right_arm_shine;

uniform vec3 left_hand;
uniform int  left_hand_shine;

uniform vec3 right_hand;
uniform int  right_hand_shine;

uniform vec3 eye_lense;
uniform int  eye_lense_shine;

uniform vec3 right_backpack;
uniform int  right_backpack_shine;

uniform vec3 left_backpack;
uniform int  left_backpack_shine;

uniform vec3 company_marks;
uniform int  company_marks_shine;

uniform vec3 robes_colour_replace;
uniform int  robes_colour_replace_shine;

uniform vec3 weapon_primary;
uniform int  weapon_primary_shine;

uniform vec3 weapon_secondary;
uniform int  weapon_secondary_shine;


varying vec2 v_vTexcoord;
varying vec4 v_vColour;

// === SHADOW AUGMENT: new uniforms ===
uniform sampler2D shadow_texture;
uniform int use_shadow;
varying vec2 v_vShadowCoord;


const float _20COL = 20.0 / 255.0;
const float _24COL = 24.0 / 255.0;
const float _46COL = 46.0 / 255.0;
const float _60COL = 60.0 / 255.0;
const float _64COL = 64.0 / 255.0;
const float _84COL = 84.0 / 255.0;
const float _104COL = 104.0 / 255.0;
const float _112COL = 112.0 / 255.0;
const float _127_25COL = 127.25 / 255.0;
const float _128COL = 128.0 / 255.0;
const float _128_75COL = 128.75 / 255.0;
const float _130COL = 130.0 / 255.0;
const float _135COL = 135.0 / 255.0;
const float _138COL = 138.0 / 255.0;
const float _140COL = 140.0 / 255.0;
const float _147COL = 147.0 / 255.0;
const float _151COL = 151.0 / 255.0;
const float _160COL = 160.0 / 255.0;
const float _165COL = 165.0 / 255.0;
const float _168COL = 168.0 / 255.0;
const float _169COL = 169.0 / 255.0;
const float _170COL = 170.0 / 255.0;
const float _181COL = 181.0 / 255.0;
const float _188COL = 188.0 / 255.0;
const float _194COL = 194.0 / 255.0;
const float _214COL = 214.0 / 255.0;
const float _215COL = 215.0 / 255.0;
const float _218COL = 218.0 / 255.0;
const float _230COL = 230.0 / 255.0;


// === Utility: RGB <-> HSV ===
vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz),
                 vec4(c.gb, K.xy),
                 step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r),
                 vec4(c.r, p.yzx),
                 step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)),
                d / (q.x + e),
                q.x);
}

vec3 hsv2rgb(vec3 c) {
    vec3 rgb = clamp(abs(mod(c.x*6.0 + vec3(0.0,4.0,2.0),
                              6.0) - 3.0) - 1.0,
                     0.0,
                     1.0);
    return c.z * mix(vec3(1.0), rgb, c.y);
}

// Shortest-path hue interpolation with clamp
float hueMixClamp(float fromHue, float toHue, float t, float maxShift) {
    // Compute shortest path delta
    float delta = mod((toHue - fromHue + 540.0), 360.0) - 180.0;
    
    // Clamp delta to maxShift (in degrees)
    if (delta > maxShift) delta = maxShift;
    if (delta < -maxShift) delta = -maxShift;

    return mod(fromHue + delta * t, 360.0);
}

vec3 light_or_dark(vec3 m_colour, float shade, float maxHueShift) {
    vec3 hsv = rgb2hsv(m_colour);

    float orig_brightness = max(m_colour.r, max(m_colour.g, m_colour.b));
    bool near_black = (orig_brightness < 0.15); // works for 35/255

    if (shade > 1.0) {
        float hue = hsv.x * 360.0;

        if (near_black) {
            // Near-black highlight: push toward green-blue (~180°), clamped
            hue = hueMixClamp(hue, 180.0, shade - 1.0, 180.0);
            hsv.z = clamp(hsv.z * shade, 0.0, 1.0);
            hsv.y = clamp(hsv.y * (2.0 - shade), 0.0, 1.0);
            hsv.x = hue / 360.0;

        } else {
            // Normal highlight: push toward yellow (60°), clamped
            hue = hueMixClamp(hue, 60.0, shade - 1.0, maxHueShift);
            hsv.z = clamp(hsv.z * shade, 0.0, 1.0);
            hsv.y = clamp(hsv.y * (2.0 - shade), 0.0, 1.0);
            hsv.x = hue / 360.0;
        }

    } else {
        // Shadow: push hue toward blue (240°), clamped
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

// === Struct for mapping ===
struct ColourMap {
    vec3 key;     // encoded colour in texture
    vec3 value;   // uniform target colour
    int shine;    // shine modifier
};

const int NUM_MAPPINGS = 27; // adjust if you add/remove mappings
ColourMap maps[NUM_MAPPINGS];

float shine_factor(int shine) {
    if (shine == 1) { return 0.25; }  // 25%
    else if (shine == 2) { return 0.50; }  // 50%
    else if (shine == 3) { return 0.75; }  // 75%
    else if (shine == 4) { return 1.0; }   // 100%
    else if (shine >= 5) { return 1.25; }  // 125%
    return 0.75;  // default fallback
}


// === Initialise all mappings ===
void init_maps() {
    maps[0]  = ColourMap(vec3(0.0, 0.0, _128COL), left_head.rgb, left_head_shine);
    maps[1]  = ColourMap(vec3(_181COL, 0.0, 1.0), right_backpack.rgb, right_backpack_shine);
    maps[2]  = ColourMap(vec3(_104COL, 0.0, _168COL), left_backpack.rgb, left_backpack_shine);
    maps[3]  = ColourMap(vec3(0.0, 0.0, 1.0), right_head.rgb, right_head_shine);
    maps[4]  = ColourMap(vec3(_128COL, _64COL, 1.0), left_muzzle.rgb, left_muzzle_shine);
    maps[5]  = ColourMap(vec3(_64COL, _128COL, 1.0), right_muzzle.rgb, right_muzzle_shine);
    maps[6]  = ColourMap(vec3(0.0, 1.0, 0.0), eye_lense.rgb, eye_lense_shine);
    maps[7]  = ColourMap(vec3(1.0, _20COL, _147COL), right_chest.rgb, right_chest_shine);
    maps[8]  = ColourMap(vec3(_128COL, 0.0, _128COL), left_chest.rgb, left_chest_shine);
    maps[9]  = ColourMap(vec3(0.0, _128COL, _128COL), right_trim.rgb, right_trim_shine);
    maps[10] = ColourMap(vec3(1.0, _128COL, 0.0), left_trim.rgb, left_trim_shine);
    maps[11] = ColourMap(vec3(_135COL, _130COL, _188COL), metallic_trim.rgb, metallic_trim_shine);
    maps[12] = ColourMap(vec3(1.0, 1.0, 1.0), right_pauldron.rgb, right_pauldron_shine);
    maps[13] = ColourMap(vec3(1.0, 1.0, 0.0), left_pauldron.rgb, left_pauldron_shine);
    maps[14] = ColourMap(vec3(0.0, _128COL, 0.0), right_leg_upper.rgb, right_leg_upper_shine);
    maps[15] = ColourMap(vec3(1.0, _112COL, _170COL), left_leg_upper.rgb, left_leg_upper_shine);
    maps[16] = ColourMap(vec3(1.0, 0.0, 0.0), left_leg_knee.rgb, left_leg_knee_shine);
    maps[17] = ColourMap(vec3(_128COL, 0.0, 0.0), left_leg_lower.rgb, left_leg_lower_shine);
    maps[18] = ColourMap(vec3(_214COL, _194COL, 1.0), right_leg_knee.rgb, right_leg_knee_shine);
    maps[19] = ColourMap(vec3(_165COL, _84COL, _24COL), right_leg_lower.rgb, right_leg_lower_shine);
    maps[20] = ColourMap(vec3(_138COL, _218COL, _140COL), right_arm.rgb, right_arm_shine);
    maps[21] = ColourMap(vec3(_46COL, _169COL, _151COL), right_hand.rgb, right_hand_shine);
    maps[22] = ColourMap(vec3(1.0, _230COL, _140COL), left_arm.rgb, left_arm_shine);
    maps[23] = ColourMap(vec3(1.0, _160COL, _112COL), left_hand.rgb, left_hand_shine);
    maps[24] = ColourMap(vec3(_128COL, _128COL, 0.0), company_marks.rgb, company_marks_shine);
    maps[25] = ColourMap(vec3(0.0, 1.0, 1.0), weapon_primary.rgb, weapon_primary_shine);
    maps[26] = ColourMap(vec3(1.0, 0.0, 1.0), weapon_secondary.rgb, weapon_secondary_shine);
}

// === Utility: approximate equality ===
bool approxEqual(float a, float b, float epsilon) {
    return abs(a - b) < epsilon;
}

bool approxEqualVec3(vec3 a, vec3 b, float epsilon) {
    return approxEqual(a.r, b.r, epsilon) &&
           approxEqual(a.g, b.g, epsilon) &&
           approxEqual(a.b, b.b, epsilon);
}

// === Core colour application function (shine + shadow integrated) ===
vec3 apply_colour(vec3 col_in, vec3 key, vec3 target, int shine, vec4 col_orig) {
    vec3 result = target;
    float eps = 0.003; // tolerance for float comparisons
    float alpha = col_orig.a;

    // === SHADOW / HIGHLIGHT HANDLING ===
    if (use_shadow != 1) {
        if (alpha > 0.49 && alpha < 0.52) {          // around _128COL
            result = light_or_dark(result, 1.2, 85.0);
        } else if (alpha > 0.22 && alpha < 0.25) {   // around _60COL
            result = light_or_dark(result, 1.4, 85.0);
        } else if (alpha > 0.83 && alpha < 0.86) {   // around _215COL
            result = light_or_dark(result, 0.6, 85.0);
        } else if (alpha > 0.62 && alpha < 0.65) {   // around _160COL
            result = light_or_dark(result, 0.8, 85.0);
        }
    } else {
        // artist-friendly shadow augment
        vec4 shadow_col = texture2D(shadow_texture, v_vShadowCoord);
        float intensity = shadow_col.r - 0.5;
        float sFactor = shine_factor(shine);
        float shadow_factor = 1.0 + (intensity * sFactor);
        result = light_or_dark(result, shadow_factor, 85.0);
    }

    return result;
}

// === Main remap function (loops mappings, early break) ===
vec3 remap_colour(vec3 col_in, vec4 col_orig) {
    float eps = 0.003; // tolerance for float comparisons
    for (int i = 0; i < NUM_MAPPINGS; i++) {
        if (approxEqualVec3(col_in, maps[i].key, eps)) {
            return apply_colour(col_in, maps[i].key, maps[i].value, maps[i].shine, col_orig);
        }
    }
    return col_in; // no match
}

// === Robes handling ===
void handle_robes(inout vec3 col) {
    float eps = 0.003;
    const vec3 robes_colour_base = vec3(201.0 / 255.0, 178.0 / 255.0, 147.0 / 255.0);
    const vec3 robes_highlight = vec3(230.0 / 255.0, 203.0 / 255.0, 168.0 / 255.0);
    const vec3 robes_darkness = vec3(189.0 / 255.0, 167.0 / 255.0, 138.0 / 255.0);
    const vec3 robes_colour_base_2 = vec3(169.0 / 255.0, 150.0 / 255.0, 123.0 / 255.0);
    const vec3 robes_highlight_2 = vec3(186.0 / 255.0, 165.0 / 255.0, 135.0 / 255.0);
    const vec3 robes_darkness_2 = vec3(148.0 / 255.0, 132.0 / 255.0, 108.0 / 255.0);

    if (approxEqualVec3(col, robes_colour_base, eps) || approxEqualVec3(col, robes_colour_base_2, eps)) {
        col = light_or_dark(robes_colour_replace , 1.0, 85.0);
    } else if (approxEqualVec3(col, robes_highlight, eps) || approxEqualVec3(col, robes_highlight_2, eps)) {
        col = light_or_dark(robes_colour_replace , 1.25, 85.0);
    } else if (approxEqualVec3(col, robes_darkness, eps) || approxEqualVec3(col, robes_darkness_2, eps)) {
        col = light_or_dark(robes_colour_replace , 0.75, 85.0);
    }
}

void main() {
    vec4 col_orig = texture2D(gm_BaseTexture, v_vTexcoord);
    if (col_orig == vec4(0.0, 0.0, 0.0, 0.0)) discard;

    // Intel fix
    float eps = 0.003;
    if (approxEqual(col_orig.r, _128COL, eps)) col_orig.r = _128COL;
    if (approxEqual(col_orig.g, _128COL, eps)) col_orig.g = _128COL;
    if (approxEqual(col_orig.b, _128COL, eps)) col_orig.b = _128COL;
    if (approxEqual(col_orig.a, _128COL, eps)) col_orig.a = _128COL;

    vec4 col = col_orig;

    init_maps();
    col.rgb = remap_colour(col.rgb, col_orig);
    col.a = 1.0;
    handle_robes(col.rgb);

    gl_FragColor = v_vColour * col;
}

