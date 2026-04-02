// CRT effect shader for Hyprland
// Stylized scanlines, screen curvature, vignette, and phosphor glow

#version 300 es

precision mediump float;
in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;
uniform sampler2D tex;

// --- Tunables ---
const float CURVATURE = 10.0; // barrel distortion strength (higher = less bent)
const float SCANLINE_STR = 0.55; // scanline darkness (0.0 = none, 1.0 = full black bars)
const float SCANLINE_CNT = 270.0; // scanline frequency — lower = thicker lines
const float SCANLINE_HARD = 4.0; // sharpness of scanline edges (higher = harder)
const float VIGNETTE_STR = 0.10; // edge darkening (lower = lighter)
const float BRIGHTNESS = 1.3; // compensate for darkening
const float BLOOM_STR = 0.2; // phosphor glow bleed
const float SATURATION = 1.3; // boost colour saturation for stylized look

// Barrel distortion
vec2 curveUV(vec2 uv) {
    uv = uv * 2.0 - 1.0;
    vec2 offset = abs(uv.yx) / CURVATURE;
    uv = uv + uv * offset * offset;
    uv = uv * 0.5 + 0.5;
    return uv;
}

// Horizontal bloom
vec3 bloom(sampler2D t, vec2 uv) {
    vec2 px = vec2(1.0 / 1920.0, 0.0);
    vec3 c =
        texture(t, uv - px * 3.0).rgb * 0.08 +
            texture(t, uv - px * 2.0).rgb * 0.15 +
            texture(t, uv - px).rgb * 0.22 +
            texture(t, uv).rgb * 0.30 +
            texture(t, uv + px).rgb * 0.22 +
            texture(t, uv + px * 2.0).rgb * 0.15 +
            texture(t, uv + px * 3.0).rgb * 0.08;
    return c;
}

// Saturate
vec3 saturate(vec3 c, float amount) {
    float luma = dot(c, vec3(0.299, 0.587, 0.114));
    return mix(vec3(luma), c, amount);
}

void main() {
    vec2 uv = curveUV(v_texcoord);

    // Black border outside curved screen
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    vec3 color = texture(tex, uv).rgb;

    // Phosphor bloom
    vec3 glow = bloom(tex, uv);
    color = mix(color, glow, BLOOM_STR);

    // Thick, hard-edged scanlines using a powered sine
    float scanline = sin(uv.y * SCANLINE_CNT * 3.14159265);
    scanline = pow(abs(scanline), SCANLINE_HARD) * sign(scanline) * 0.5 + 0.5;
    color *= mix(1.0 - SCANLINE_STR, 1.0, scanline);

    // Vignette
    vec2 vig = uv * (1.0 - uv);
    float vignette = clamp(pow(vig.x * vig.y * 20.0, VIGNETTE_STR), 0.0, 1.0);
    color *= vignette;

    // Brightness + saturation boost
    color *= BRIGHTNESS;
    color = saturate(color, SATURATION);

    fragColor = vec4(color, 1.0);
}
