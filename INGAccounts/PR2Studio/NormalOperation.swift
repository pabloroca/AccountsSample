//
//  NormalOperation.swift
//  Operations1
//
//  Created by Pablo Roca Rozas on 26/5/16.
//  Copyright © 2016 PR2Studio. All rights reserved.
//

import Foundation

class NormalOperation : Operation {
   
   let jname: String
   
   init(name: String) {
      self.jname = name
   }
   
   override func main() {
      print("start \(self.jname)")
      var maxcount = 1000000
      var total = 0.0
      if self.jname == "jar3" {
         maxcount = 4000000
      }
      for i in 0...maxcount {
         total += Double(i)*256.0
      }
      print("finish \(self.jname)")
   }
   
   override func cancel() {
      super.cancel()
   }

}
