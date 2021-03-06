//
//  ViewController.swift
//  pokedox
//
//  Created by Tushar Katyal on 06/08/17.
//  Copyright © 2017 Tushar Katyal. All rights reserved.
//

import UIKit
import AVFoundation

class MainVC: UIViewController , UICollectionViewDelegate,UICollectionViewDataSource , UICollectionViewDelegateFlowLayout ,UISearchBarDelegate{

    @IBOutlet weak var collection: UICollectionView!
    var pokemon = [Pokemon]()
    var filteredPokemon = [Pokemon]()
    var musicPlayer : AVAudioPlayer!
    var isSearchActive = false
    
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        collection.delegate = self
        collection.dataSource = self
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        parsePokemonCSV()
        initAudio()
        
    }
    
    
    

    func initAudio(){
        
        let path = Bundle.main.path(forResource: "music", ofType: "mp3")!
        
        do {
            
            musicPlayer = try AVAudioPlayer(contentsOf: URL(string :path)!)
            musicPlayer.prepareToPlay()
            musicPlayer.numberOfLoops = -1
            
        } catch let err as NSError {
            print(err.debugDescription)
        }
        
    }
    func parsePokemonCSV(){
        
        let path = Bundle.main.path(forResource: "pokemon", ofType: "csv")!
        
        do {
            
            let csv = try CSV(contentsOfURL: path)
            let rows = csv.rows
            for row in rows {
                
                let pokeId = Int(row["id"]!)!
                let pokeName = row["identifier"]!
                let poke = Pokemon(name: pokeName, pokedoxId: pokeId)
                
                pokemon.append(poke)
            }
            
        } catch let err as NSError{
            
            
            print(err.debugDescription)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokeCell", for: indexPath) as? PokeCell
        {
            let poke : Pokemon!
            
            if isSearchActive {
                
                poke = filteredPokemon[indexPath.row]
                cell.configureCell(pokemon: poke)
            }
            else {
                poke = pokemon[indexPath.row]
                cell.configureCell(pokemon: poke)
            }
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearchActive{
            return filteredPokemon.count
        }
        return pokemon.count    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        var poke : Pokemon!
        
        if isSearchActive {
            poke = filteredPokemon[indexPath.row]
        }
        else {
            poke = pokemon[indexPath.row]
        }
        performSegue(withIdentifier: "PokemonDetailsVC", sender: poke)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 105, height: 105)
    }

    @IBAction func musicBtnPressed(_ sender: UIButton) {
        
        if musicPlayer.isPlaying {
            musicPlayer.pause()
            sender.alpha = 0.2
            
        }
        else {
            musicPlayer.play()
            sender.alpha = 1.0
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == nil || searchBar.text == "" {
            isSearchActive = false
            collection.reloadData()
            view.endEditing(true)
        }
        
        else {
            isSearchActive = true
            let lower = searchBar.text!.lowercased()
            filteredPokemon = pokemon.filter({$0.name.range(of: lower) != nil })
            collection.reloadData()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "PokemonDetailsVC" {
            
            if  let detailsVC = segue.destination as? PokemonDetailsVC {
                if let poke = sender as? Pokemon {
                    detailsVC.pokemon = poke
                }
            }
        }
        
    }
}

