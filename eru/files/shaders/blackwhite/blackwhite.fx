// Original https://community.multitheftauto.com/index.php?p=resources&s=details&id=8466
// blackwhite.fx
// Edited by Feche for ERU :]

texture screenSource;
float strong;
 
sampler TextureSampler = sampler_state
{
    Texture = <screenSource>;
};

float4 PixelShaderFunction(float2 TextureCoordinate : TEXCOORD0) : COLOR0
{
    float4 color = tex2D(TextureSampler, TextureCoordinate);
 
    color.r = color.r / strong;
    color.g = color.g / strong;
    color.b = color.b / strong;
	
    return color.r + color.g + color.b;
}
 
technique BlackAndWhite
{
    pass Pass1
    {
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}