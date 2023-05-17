import bpy
import numpy as np
import math

# Args
TextureName = 'Sample'
TextureResolution = 64
TextureMode = 'Create'
#TextureMode = 'Overwrite'


class ImageOperator:
    def __init__(self, texName, div, texMode):
        self.length = div * 2

        if texMode == 'Create':
            self.blimg = bpy.data.images.new(texName, self.length, self.length, alpha=True)
        else:
            self.blimg = bpy.data.images[texName]
        
        self.blimg.pixels = [0.0] * self.length * self.length * 4
        
        self.point_ = np.array(self.blimg.pixels[:])
        self.point_.resize(self.length, self.length * 4)
        
        self.point_R = self.point_[::, 0::4]
        self.point_G = self.point_[::, 1::4]
        self.point_B = self.point_[::, 2::4]
        self.point_A = self.point_[::, 3::4]

    def ConvertUVTo4Pixel(self, u, v):
        x = int(u * (self.length))
        y = int(v * (self.length))
        
        result = []
        result.append([y  , x  ])
        result.append([y  , x+1])
        result.append([y+1, x  ])
        result.append([y+1, x+1])
        
        return result

    def SetColor(self, py, px, r, g, b, a):
        self.point_R[py][px] = r
        self.point_G[py][px] = g
        self.point_B[py][px] = b
        self.point_A[py][px] = a
        
    def CreateResult(self):
        self.blimg.pixels = self.point_.flatten()
    
    
class UVOperator:
    def __init__(self, div):
        self.div = div
        self.d = (1 / self.div)
        self.x = 0
        self.y = 0
    
    def GetNextUV(self):
        result = ([self.x * self.d, self.y * self.d])
        
        self.x += 1
        
        if self.x == self.div:
            self.x = 0
            self.y += 1
            
        return result


def ConvertValueToColor(num):
    def GetExponent(num):
        if(num == 0):
            return 0
        
        return int(math.log10(abs(num)))

    def ConvertSignificandToRGB(significand):
        result = []
        
        for i in range(3):
            significand *= 255
            result.append(int(significand))
            significand -= result[i]
            
        return result

    exponent = GetExponent(num)
    significand = abs(num) / (10 ** exponent)
    
    result = ConvertSignificandToRGB(significand)
    
    # Alpha must be greater than 0(7bit = 1)
    alpha = 128
    alpha += abs(exponent)
    
    if(exponent < 0):
        alpha += 32
    
    if(num < 0):
        alpha += 64
    
    result.append(alpha)
    
    return [i / 255 for i in result]

def ConvertNormalToColor(x,y,z):
    result = [abs(x), abs(y), abs(z)]
    
    alpha = 255
    
    if(x < 0):
        alpha -= 128
        
    if(y < 0):
        alpha -= 64
        
    if(z < 0):
        alpha -= 32
    
    return [*result, alpha / 255]


vps = int(TextureResolution / 2)
image = ImageOperator(TextureName, vps, TextureMode)
uv = UVOperator(vps)

mesh = bpy.context.object.data
uv_layer = mesh.uv_layers.active.data
vartices = bpy.context.object.data.vertices

for polygon in mesh.polygons:
    for index in range(polygon.loop_start, polygon.loop_start + polygon.loop_total):
        uv_layer[index].uv = uv.GetNextUV()
        
        points = image.ConvertUVTo4Pixel(*uv_layer[index].uv)
        
        for dir in range(3):
            rgba = ConvertValueToColor(vartices[mesh.loops[index].vertex_index].co[dir])
            image.SetColor(*points[dir], *rgba)
        
        image.SetColor(*points[3], *ConvertNormalToColor(*polygon.normal))

image.CreateResult()
