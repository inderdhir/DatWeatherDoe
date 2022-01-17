//
//  ForwardPipe.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/15/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

precedencegroup ForwardPipe {
    associativity: left
}

infix operator |>: ForwardPipe

func |> <T, U>(value: T, function: (T) -> U) -> U {
    function(value)
}
