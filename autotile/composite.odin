package autotile

import rl "vendor:raylib"

TILE_LOCATIONS := make(map[int][2]int)

generate_all_tile_combos :: proc(texture: cstring, keys: [][2]int, cell_size: i32, start_row: i32) {

    texture_image := rl.LoadImage(texture)
    defer rl.UnloadImage(texture_image)
    
    canvas := rl.GenImageColor(texture_image.width, texture_image.height*10, rl.BLANK)
    defer rl.UnloadImage(canvas)

    rl.ImageDraw(&canvas, texture_image, 
        rl.Rectangle{0, 0, f32(texture_image.width), f32(texture_image.height)},
        rl.Rectangle{0, 0, f32(texture_image.width), f32(texture_image.height)},
        rl.WHITE
    )

    used_positions: [dynamic][2]int
    col_amount := texture_image.width/cell_size
    cur_col :i32= 0
    cur_row :i32= start_row

    for k1, i1 in keys {
        for k2, i2 in keys {
            if i1 == i2 {
                continue
            }
            for bit in 1..<14 {
                p := select_tile_type(bit)
                t1_pos := [2]int{p[0]+k1[0], p[1]+k1[1]}
                source_rect2 := rl.Rectangle{
                    x=f32(t1_pos[0]*32),
                    y=f32(t1_pos[1]*32),
                    width=32,
                    height=32
                }
                for bit_2 in 1..<14 {
                    if bit == bit_2 {
                        continue
                    }
                    p2 := select_tile_type(bit_2)
                    t2_pos := [2]int{p[0]+k2[0], p2[1]+p2[1]}
                    source_rect1 := rl.Rectangle{
                        x=f32(t2_pos[0]*32),
                        y=f32(t2_pos[1]*32),
                        width=32,
                        height=32
                    }

                    dest_position := [2]f32{
                        f32(cur_col*cell_size),
                        f32(cur_row*cell_size)
                    }

                    portion1 := rl.ImageFromImage(texture_image, source_rect1)
                    portion2 := rl.ImageFromImage(texture_image, source_rect2)
                    rl.ImageDraw(&canvas, portion1, rl.Rectangle{0,0,f32(portion1.width), f32(portion1.height)},
                        rl.Rectangle{dest_position.x, dest_position.y, f32(portion1.width), f32(portion1.height)},
                        rl.WHITE
                    )
                    rl.ImageDraw(&canvas, portion2, rl.Rectangle{0,0,f32(portion2.width), f32(portion2.height)},
                        rl.Rectangle{dest_position.x, dest_position.y, f32(portion2.width), f32(portion2.height)},
                        rl.WHITE
                    )
                    rl.UnloadImage(portion1)
                    rl.UnloadImage(portion2)

                    if cur_col > col_amount {
                        cur_col = 0
                        cur_row += 1
                    } else {
                        cur_col += 1
                    }
                }
            }
        }
    }

    rl.ExportImage(canvas, "extended_transparent_image.png")
}