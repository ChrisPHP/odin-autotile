package main

import "core:fmt"
import "core:math/noise"
import "core:math/rand"
import rl "vendor:raylib"
import "core:mem"
import "core:math"

import auto "autotile"

CELL_SIZE :: 32
TEXTURE: rl.Texture

gen_noise_map :: proc(baseFrequency: f64, cellSize: f64, octaves: i8, persistance: f64, lacunarity: f64, seed: i64, coords: [2]int) -> f32 {
    totalNoise: f32
    frequency: f64 = baseFrequency / cellSize
    amplitude: f64 = 2.0
    maxValue: f64

    for i in 0..<octaves {
        totalNoise += noise.noise_2d(seed, {f64(coords[0])*frequency,f64(coords[1])*frequency}) * f32(amplitude)

        maxValue += amplitude
        amplitude *= persistance
        frequency *= lacunarity
    }
    return totalNoise / f32(maxValue)
}

gen_map :: proc(width, height: int) -> []int {
    grid := make([]int, width*height)
    seed := rand.int63()
    for x in 0..<width {
        for y in 0..<height {
            noise_value := gen_noise_map(0.2, 5, 2, 0.5, 4, seed, {x, y})
            size := y * width + x
            if noise_value < 0 {
                grid[size] = 0
            } else {
                grid[size] = 1
            }
        }
    }
    return grid
}

render_texture :: proc(x: int, y: int, pos: [2]int) {
    tile_x := pos[0]
    tile_y := pos[1]
    rect := rl.Rectangle{f32(tile_x)*CELL_SIZE, f32(tile_y)*CELL_SIZE, CELL_SIZE, CELL_SIZE}
    tileDest := rl.Rectangle{f32(x)*CELL_SIZE, f32(y)*CELL_SIZE, CELL_SIZE, CELL_SIZE}

    origin:f32  = CELL_SIZE / 2

    rl.DrawTexturePro(TEXTURE, rect, tileDest, rl.Vector2{-origin, -origin}, 0, rl.WHITE)
}

main :: proc() {
    tracking_allocator: mem.Tracking_Allocator
    mem.tracking_allocator_init(&tracking_allocator, context.allocator)
    defer mem.tracking_allocator_destroy(&tracking_allocator)
    context.allocator = mem.tracking_allocator(&tracking_allocator)
    defer {
        fmt.printfln("MEMORY SUMMARY")
        for _, leak in tracking_allocator.allocation_map {
            fmt.printfln(" %v leaked %m", leak.location, leak.size)
        }
        for bad_free in tracking_allocator.bad_free_array {
            fmt.printfln(" %v allocation %p was freed badly", bad_free.location, bad_free.memory)
        }
    }

    rl.InitWindow(1600, 1600, "AutoTile")
    rl.SetTargetFPS(60)

    TEXTURE = rl.LoadTexture("wang2e.png")

    grid_width := 50
    grid_height := 50
    
    grid := gen_map(grid_width,grid_height)
    defer delete(grid)

    auto.initialise_bit_level(50, 50)
    auto.create_4bit_mask(&grid)


    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)

        for x in 0..<grid_width {
            for y in 0..<grid_height {
                size := y * grid_width + x
                value := grid[size]
                pos := auto.select_tile_type_4bit(x, y, auto.BIT_GRID[size])
                render_texture(x,y, pos)
            }
        }

        rl.EndDrawing()
    }

    rl.CloseWindow()

    auto.clear_grid_memory()
}