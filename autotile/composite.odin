package autotile

import rl "vendor:raylib"

TILE_LOCATIONS := make(map[int][2]int)

generate_all_tile_combos :: proc(texture: cstring, keys: [][2]int) {

    texture_image := rl.LoadImage(texture)
    defer rl.UnloadImage(texture_image)
    
    canvas := rl.GenImageColor(texture_image.width, texture_image.height*2, rl.BLANK)
    defer rl.UnloadImage(canvas)

    rl.ImageDraw(&canvas, texture_image, 
        rl.Rectangle{0, 0, f32(texture_image.width), f32(texture_image.height)},
        rl.Rectangle{0, 0, f32(texture_image.width), f32(texture_image.height)},
        rl.WHITE
    )

    for k1, i1 in keys {
        for k2, i2 in keys {
            if i1 == i2 {
                continue
            }
            for bit in 1..<14 {
                p := select_tile_type(bit)
                t1_pos := [2]int{p[0]+k1[0], p[1]+k1[1]}
                t2_pos := [2]int{p[0]+k2[0], p[1]+k2[1]}

                source_rect := rl.Rectangle{
                    x=f32(t2_pos[0]*32),
                    y=f32(t2_pos[1]*32),
                    width=32,
                    height=32
                }
                
                dest_position := [2]f32{
                    0,
                    4*32
                }

                portion := rl.ImageFromImage(texture_image, source_rect)
                rl.ImageDraw(&canvas, portion, rl.Rectangle{0,0,f32(portion.width), f32(portion.height)},
                    rl.Rectangle{dest_position.x, dest_position.y, f32(portion.width), f32(portion.height)},
                    rl.WHITE
                )
            }
        }
    }
}