shader_type canvas_item;

uniform vec4 rim_color : source_color = vec4(0.8, 0.95, 1.0, 1.0);
uniform vec4 inner_color : source_color = vec4(0.5, 0.8, 1.0, 0.15);
uniform vec4 highlight_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float rim_width : hint_range(0.01, 0.5) = 0.08;
uniform float bubble_speed : hint_range(0.1, 3.0) = 0.8;

void fragment() {
    vec2 uv = UV * 2.0 - 1.0;
    float dist = length(uv);

    float circle_mask = 1.0 - smoothstep(0.9, 1.0, dist);
    float rim = smoothstep(1.0 - rim_width, 1.0, dist);

    float highlight = smoothstep(0.4, 0.0,
        length((uv - vec2(-0.3, -0.4)) * vec2(1.0, 1.5)));
    float highlight2 = smoothstep(0.15, 0.0,
        length(uv - vec2(0.35, 0.38))) * 0.6;

    float shimmer = sin(atan(uv.y, uv.x) * 6.0
        + TIME * bubble_speed) * 0.04 + 0.04;
    float shimmer_mask = smoothstep(0.5, 0.95, dist);

    vec3 col = mix(inner_color.rgb, rim_color.rgb, rim);
    col += highlight_color.rgb * highlight;
    col += highlight_color.rgb * highlight2;
    col += shimmer * shimmer_mask;

    float alpha = mix(inner_color.a, rim_color.a, rim);
    alpha += highlight * 0.8;
    alpha += highlight2 * 0.4;
    alpha += shimmer * shimmer_mask;
    alpha *= circle_mask;
    alpha = clamp(alpha, 0.0, 1.0);

    COLOR = vec4(col, alpha);
}