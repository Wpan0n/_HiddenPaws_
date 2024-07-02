// Fireworks shader
// Based on shadertoy shader by Martijn Steinrucken aka BigWings - 2015 
// (https://www.shadertoy.com/view/lscGRl)

shader_type canvas_item;

// Constants
uniform int NUM_EXPLOSIONS = 8; // Number of fireworks
uniform int NUM_PARTICLES = 20; // Number of particles per firework
uniform vec2 iResolution = vec2(600.0, 400.0); // Resolution of the screen

// Noise functions by Dave Hoskins
uniform vec3 MOD3 = vec3(0.1031, 0.11369, 0.13787); // Constants used for hashing

// Hash function to generate pseudo-random 3D vectors from a float
vec3 hash31(float p) {
    vec3 p3 = fract(vec3(p) * MOD3);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract(vec3((p3.x + p3.y) * p3.z, (p3.x + p3.z) * p3.y, (p3.y + p3.z) * p3.x));
}

// Hash function to generate a pseudo-random float from a 2D vector


// Function to create a lighter effect
float lighter(vec2 uv, vec2 pos, float size) {
    uv -= pos;
    size *= size;
    return size / dot(uv, uv);
}

// Function to create a single explosion
vec3 explosion(vec2 uv, vec2 p, float seed, float t) {
    vec3 col = vec3(0.0); // Initialize color
    vec3 en = hash31(seed); // Generate a random base color
    vec3 baseCol = en; // Base color for the explosion

    for (int i = 0; i < NUM_PARTICLES; i++) {
        vec3 n = hash31(float(i)) - 0.5; // Generate a random direction
        vec2 startP = p - vec2(0.0, t * t * 0.1); // Starting point of the particle
        vec2 endP = startP + normalize(n.xy) * n.z; // Ending point of the particle

        float pt = 1.0 - pow(t - 1.0, 2.0); // Time progression
        vec2 pos = mix(p, endP, pt); // Interpolated position
        float size = mix(0.01, 0.005, smoothstep(0.0, 0.1, pt)); // Particle size
        size *= smoothstep(1.0, 0.1, pt); // Smooth transition for size

        float sparkle = (sin((pt + n.z) * 100.0) * 0.5 + 0.5); // Sparkle effect
        sparkle = pow(sparkle, pow(en.x, 3.0) * 50.0) * mix(0.01, 0.01, en.y * n.y);
        float B = smoothstep(en.x - en.z, en.x + en.z, t) * smoothstep(en.y + en.z, en.y - en.z, t);
        size += sparkle * B; // Add sparkle to size

        col += baseCol * lighter(uv, pos, size); // Add particle color to the explosion color
    }
    
    return col; // Return the explosion color
}

void fragment() {
    vec2 uv = FRAGCOORD.xy / iResolution.xy; // Normalize coordinates
    uv.x -= 0.5; // Center the coordinates
    uv.x *= iResolution.x / iResolution.y; // Maintain aspect ratio
    

    float t = TIME * 0.5; // Scale time for slower animation
    vec3 c = vec3(0.0); // Initialize color

    for (int i = 0; i < NUM_EXPLOSIONS; i++) {
        float et = t + float(i) * 1234.45235; // Unique time for each explosion
        float id = floor(et); // Explosion ID
        et -= id; // Explosion progress

        vec2 p = hash31(id).xy; // Position of the explosion
        p.x -= 0.5; // Center the position
        p.x *= 1.6; // Adjust position for aspect ratio
        c += explosion(uv, p, id, et); // Add explosion color to the final color
    }
    
    float alpha = length(c) > 1.0 ? 2.0 : 0.0; // Set alpha based on brightness of the color
    COLOR = vec4(c, alpha); // Set the final color with transparency
}
