//
// warpedSiveWave.fx
// http://glslsandbox.com/e#26939.0
// glsl to hlsl translation by Ren712

//------------------------------------------------------------------------------------------
// Shader settings
//------------------------------------------------------------------------------------------
float2 sTexSize = float2(800,600);
float2 sScale = float2(1,1);
float2 sCenter = float2(0.5,0.5);

//------------------------------------------------------------------------------------------
// These parameters are set by MTA whenever a shader is drawn
//------------------------------------------------------------------------------------------
float4x4 gWorld : WORLD;
float4x4 gView : VIEW;
float4x4 gProjection : PROJECTION;
float gTime : TIME;
#define PI 3.1415926535897

//------------------------------------------------------------------------------------------
// Structure of data sent to the vertex shader
//------------------------------------------------------------------------------------------
struct VSInput
{
    float3 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

//------------------------------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//------------------------------------------------------------------------------------------
struct PSInput
{
    float4 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float2 TexCoord: TEXCOORD0;
};

//------------------------------------------------------------------------------------------
// VertexShaderFunction
//------------------------------------------------------------------------------------------
PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;

    // Calculate screen pos of vertex
    float4 posWorld = mul(float4(VS.Position.xyz,1), gWorld);
    float4 posWorldView = mul(posWorld, gView);
    PS.Position = mul(posWorldView, gProjection);
	
    // Pass through color and tex coord
    PS.Diffuse = VS.Diffuse;

    // Translate TexCoord
    float2 position = float2(VS.TexCoord.x,1 - VS.TexCoord.y);
    float2 center = 0.5 + (sCenter - 0.5);
    position += float2(1 - center.x, center.y) - 0.5;
    position = (position - 0.5) * float2(sTexSize.x/sTexSize.y,1) / sScale + 0.5;
    position -= 0.5;
    PS.TexCoord = position;

    return PS;
}

//------------------------------------------------------------------------------------------
// PixelShaderFunction
//------------------------------------------------------------------------------------------
float4 PixelShaderFunction(PSInput PS) : COLOR0
{   
    // Get TexCoord
    float2 position = PS.TexCoord;
    float timer = gTime;

    float t = abs( 1.0 / (sin( position.y + sin( timer + position.x * 10.0 ) * position.x ) * 10.0) );
    float3 finalColor = float3( t * 0.1, t * 0.1, t * 0.8 );

    return float4( finalColor, 1.0 );
}

//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique warpedSiveWave
{
    pass P0
    {
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader  = compile ps_2_0 PixelShaderFunction();
    }
}

// Fallback
technique fallback
{
    pass P0
    {
        // Just draw normally
    }
}
