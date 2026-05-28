//
//  ContentView.swift
//  Snaek
//
//  Created by Invitado on 27/05/26.
//

import SwiftUI

struct coord : Hashable {
    var x:Int
    var y:Int
}

struct ContentView: View {
    let celSize = 15
    @State private var manzanaCoord: coord = coord(x:5,y:6)
    @State private var manzanaComida = false
    @State private var cuerpo:Array<coord> = [coord(x:5,y:6),coord(x:5,y:5)]
    @State private var direccion:Array<CGFloat> = [0,0]
    @State private var highscore: Int = 0
    @State private var score: Int = 0
    @State private var bodySet:Set<coord> = Set()
    @State private var juegoCorriendo = false

    var body: some View {
        VStack {
            //Marcadores
            HStack {
                Label("Highscore: \(highscore)", systemImage: "trophy.fill")
                    .font(.headline)
                Spacer() // Separa los dos labels a los extremos
                Label("Score: \(score)", systemImage: "apple.logo")
                    .font(.headline)
            }
            .padding() // Margen interno para los marcadores
            Spacer()
            ZStack{
                //serpiente
                ForEach(cuerpo.indices, id:\.self){i in
                    RoundedRectangle(cornerRadius: 5)
                        .offset(x: CGFloat(cuerpo[i].x * celSize),y: CGFloat(cuerpo[i].y * celSize))
                        .frame(width:CGFloat(celSize),height:CGFloat(celSize))
                        .foregroundColor(.green)
                }
                
                //manzana
                RoundedRectangle(cornerRadius: 5)
                    .offset(x:CGFloat(manzanaCoord.x * celSize), y: CGFloat(manzanaCoord.y * celSize))
                    .foregroundColor(.red)
                    .frame(width:CGFloat(celSize),height:CGFloat(celSize))
            }.gesture(DragGesture().onEnded{value in guardarDireccion(value)})
                .frame(width:CGFloat(25 * celSize), height: CGFloat(25 * celSize))
                .background(.gray)
            Spacer() // Empuja los marcadores arriba y el botón abajo
            
            //Botón de JUGAR
            HStack {
                Button(action: iniciarJuego) {
                    Label("JUGAR", systemImage: "play.fill")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity) // Usa el ancho disponible
                        .background(Color.blue)
                        .cornerRadius(10)
                        .opacity(juegoCorriendo ? 0: 1)
                }
            }
            .padding() // Margen interno para el área del botón
        }
    }
    func guardarDireccion(_ value: DragGesture.Value){
        if abs(value.translation.width) > abs(value.translation.height){
            direccion[0] = value.translation.width/abs(value.translation.width)
            direccion[1] = 0
        }else{
            direccion[0] = 0
            direccion[1] = value.translation.height/abs(value.translation.height)
        }
    }
    
    func iniciarJuego() -> Void{
        //Estoy usando un timer como "game loop", la vdd esto solo funciona porque es el juego
        //de la serpiente
        juegoCorriendo = true
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true){timer in
            ///SERPIENTE
            //muevo la serpiente
            var lastPos = cuerpo[0]
            
            cuerpo[0].x += Int(direccion[0])
            cuerpo[0].y += Int(direccion[1])
            
            var i = 1
            var auxPos = cuerpo[i]
            while i < cuerpo.count{
                auxPos = cuerpo[i]
                cuerpo[i] = lastPos
                lastPos = auxPos
                
                i += 1
            }
            
            if manzanaComida{
                cuerpo.append(lastPos)
            }
            
            //checo si choca con algo
            //cuerpo
            bodySet = Set(cuerpo[1...])
            if bodySet.contains(cuerpo[0]){
                perder(timer)
            }
            //pared
            if cuerpo[0].x > 25 * celSize || cuerpo[0].x < 0 || cuerpo[0].y > 25 * celSize || cuerpo[0].y < 0{
                perder(timer)
            }
            
            ///MANZANA
            if manzanaComida { //si fue comida, se mueve
                manzanaCoord = randCoord()
                manzanaComida = false
            } else { //si no, checa si fue comida
                if cuerpo[0] == manzanaCoord{
                    manzanaComida = true
                    score += 100
                }
            }
        }
    }
    
    func perder(_ timer:Timer){
        //mato el timer
        timer.invalidate()
        
        //reseteo las variables
        juegoCorriendo = false
        manzanaCoord = randCoord()
        manzanaComida = false
        cuerpo = [coord(x:5,y:6),coord(x:5,y:5)]
        direccion = [0,0]
        score = 0
        bodySet = Set(cuerpo[1...])
        juegoCorriendo = false
    }
    
    func randCoord() -> coord{
        return coord(x:Int.random(in: 0...24),y:Int.random(in: 0...24))
    }

}

