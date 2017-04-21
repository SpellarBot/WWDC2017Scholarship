import Cocoa

public class Perlin2D: NSObject {
    
    let boolValue:CGFloat = 0.49
    
    var permutation:[Int] = []
    
    
    public init(seed: String) {
        
        let hash = seed.hash
        
        srand48(hash)
        
        for _ in 0..<512 {
            //Create the permutations to pick from using a seed so you can recreate the map
            permutation.append(Int(drand48() * 255))
        }
    }
    
    
    func lerp(a:CGFloat, b:CGFloat, x:CGFloat) -> CGFloat {
        return a + x * (b - a) //This interpolates between two points with a weight x
    }
    
    func fade(t:CGFloat) -> CGFloat {
        return t * t * t * (t * (t * 6 - 15) + 10) //This is the smoothing function for Perlin noise
    }
    
    func grad(hash:Int, x:CGFloat, y:CGFloat) -> CGFloat {
        
        //This takes a hash (a number from 0 - 5) generated from the random permutations and returns a random
        //operation for the node to offset
        
        switch hash & 3 {
        case 0:
            return x + y
        case 1:
            return -x + y
        case 2:
            return x - y
        case 3:
            return -x - y
        default:
            print("ERROR")
            return 0
        }
        
        
    }
    
    func fastfloor(x:CGFloat) -> Int {
        return x >= 0 ? Int(x) : Int(x)
    }
    
    public func noise(x:CGFloat, y:CGFloat) -> CGFloat {
        
        //Find the unit grid cell containing the point
        var xi = fastfloor(x: x)
        var yi = fastfloor(x: y)
        
        //This is the other bound of the unit square
        let xf:CGFloat = x - CGFloat(xi)
        let yf:CGFloat = y - CGFloat(yi)
        
        //Wrap the ints around 255
        xi = xi & 255
        yi = yi & 255
        
        //These are offset values for interpolation
        let u = fade(t: xf)
        let v = fade(t: yf)
        
        
        //These are the 4 possible permutations so we get the perm value for each
        let aa = permutation[permutation[xi] + yi]
        let ab = permutation[permutation[xi] + yi + 1]
        let ba = permutation[permutation[xi + 1] + yi]
        let bb = permutation[permutation[xi + 1] + yi + 1]
        
        
        //We pair aa and ba, and ab and bb and lerp the gradient of the two, using the offset values
        //We take 1 off the value which we added one to for the perms
        let x1 = lerp(a: grad(hash: aa, x: xf, y: yf), b: grad(hash: ba, x: xf - 1, y: yf), x: u)
        let x2 = lerp(a: grad(hash: ab, x: xf, y: yf - 1), b: grad(hash: bb, x: xf - 1, y: yf - 1), x: u)
        let y1 = lerp(a: x1, b: x2, x: v)
        
        
        
        //We return the value + 1 / 2 to remove any negatives.
        return (y1 + 1) / 2
    }
    
    
    public func octaveNoise(x:CGFloat, y:CGFloat, octaves:Int, persistence:CGFloat) -> CGFloat {
        
        //This takes several perlin readings (n octaves) and merges them into one map
        var total:CGFloat = 0
        var frequency: CGFloat = 1
        var amplitude: CGFloat = 1
        var maxValue: CGFloat = 0
        
        //We sum the total and divide by the max at the end to normalise
        for _ in 0..<octaves {
            total += noise(x: x * frequency, y: y * frequency) * amplitude
            
            maxValue += amplitude
            
            //This is taken from recomendations on values
            amplitude *= persistence
            frequency *= 2
        }
        
        //print(max)
        
        return total/maxValue
    }

    
    public func perlinMatrix(width:Int, height: Int) -> [[CGFloat]] {
        
        var map:[[CGFloat]] = []
        
        //We loop through the x and y values and scale by 50. This is an arbritatry value to scale the map
        //You can play with this
        for x in (0..<width) {
            
            var row:[CGFloat] = []
            
            for y in (0..<height) {
                let cx:CGFloat = CGFloat(x)/50
                let cy:CGFloat = CGFloat(y)/50
                
                
                let p = noise(x: cx, y: cy)
                
                row.append(p)
            }
            
            //We store the map in a matrix for fast access
            map.append(row)
        }
        
        return map
        
        
    }
    
    
    public func octaveMatrix(width:Int, height: Int, octaves:Int, persistance:CGFloat) -> [[CGFloat]] {
        
        var map:[[CGFloat]] = []
        
        //We loop through the x and y values and scale by 50. This is an arbritatry value to scale the map
        //You can play with this
        for x in (0..<width) {
            
            var row:[CGFloat] = []
            
            for y in (0..<height) {
                let cx:CGFloat = CGFloat(x)/50
                let cy:CGFloat = CGFloat(y)/50
                
                //We decide to use 8 octaves and 0.25 to generate our map. You can change these too
                let p = octaveNoise(x: cx, y: cy, octaves: octaves, persistence: persistance)
                
                row.append(p)
            }
            
            //We store the map in a matrix for fast access
            map.append(row)
        }
        
        return map
        

    }
    
    public func booleanOctaveMatrix(width:Int, height: Int, octaves:Int, persistance:CGFloat) -> [[CGFloat]] {
        
        var map:[[CGFloat]] = []
        
        //We loop through the x and y values and scale by 50. This is an arbritatry value to scale the map
        //You can play with this
        for x in (0..<width) {
            
            var row:[CGFloat] = []
            
            for y in (0..<height) {
                let cx:CGFloat = CGFloat(x)/50
                let cy:CGFloat = CGFloat(y)/50
                
                //We decide to use 8 octaves and 0.25 to generate our map. You can change these too
                let p = octaveNoise(x: cx, y: cy, octaves: octaves, persistence: persistance)
                
                
                if (p >= boolValue) {
                    row.append(1)
                } else {
                    row.append(0)
                }
                
            }
            
            //We store the map in a matrix for fast access
            map.append(row)
        }
        
        return map
        
        
    }

}
