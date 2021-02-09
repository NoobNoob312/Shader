// template: https://www.shadertoy.com/view/Wtffzn
// https://thebookofshaders.com/12/?lan=de ->Voronoi

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

uniform float cellDiffusion;
uniform float cellZoom;
uniform float cellRed;  
uniform float cellGreen; 
uniform float cellBlue; 
uniform float cellMovement;

vec3 backgroundColor = vec3(0.0);

vec2 random( vec2 p ) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

void main()
{
   
    // Normalized pixel coordinates (from 0 to 1)
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    // adapt aspect ratio 
    st.y *= u_resolution.y/u_resolution.x;    
    
    //tile
	st *= cellZoom;  //multiply view / coord. system
    vec2 i_st = floor(st);  // floor(x): next int smaller or equal x -> to chose tile 0.... 
    vec2 f_st = fract(st);  // fract(x): after comma part -> position in tile
    vec3 col = vec3(0.0, 0.0, 0.0);
    
    
    //cell
    float m_dist = 1.;  // Minimum Distanz
    
    for(int y = -1; y <= 1; y++)
    {
        for(int x = -1; x <= 1; x++)
        {
            vec2 neighbor = vec2(float(x), float(y)); //neighbor position in tiles
            
            vec2 point = random(i_st + neighbor); //random current position + Neighbor position in grid
            
            point = vec2(.5) + .5 * (sin(cellMovement + 6.075 * point)); // u_time: cells movement from point is between 0 and 1
                   
            vec2 diff = neighbor + point - f_st; // vector between pixel and point 
            
            float dist = length(diff); // Distance to the point
            
            m_dist = min(m_dist, dist); // min(x, y): return minimum value-> closer distance  
        }
    }

    
    col += m_dist;  // draw minimum distance (Distance Field)
    col -= clamp(sin(1.*m_dist), 0., 1.) * cellDiffusion;   // min(max(sin(1.*m_dist), minVal), maxVal) -> Value between 0 and 1
    
    //coloring
    col.r += cellRed;     
    col.g += cellGreen; 
    col.b += cellBlue;
  
    // Output to screen
    gl_FragColor = vec4(col, 1.0);
}
        
        
