//
//  NetworkSession.swift
//  LeadRoom
//
//  Created by Nikhil Vivek Dhavale on 02/08/20.
//  Copyright © 2020 Nikhil. All rights reserved.
//

import Foundation
import Mixpanel

enum Result<Success,Failure:Error>
{
    case success(Success)
    case failure(Failure)
}
enum NEError:String,Error
{
    case noData = "No Data"
    case badURL = "Bad url"
    case badParams = "Bad Params"
    case login = "Session expired"
    case otherError = "Please try again"
}

struct NetworkSession
{
    let completion:(Result<Data, Error>) -> ()
    let urlSession = URLSession.shared
    func setupGetRequest(urlString:String)
    {
        handleRquest(urlString: urlString, body: nil, method: "GET")
        
    }
    func setupPostRequest(urlString:String,body:Encodable?)
    {
        handleRquest(urlString: urlString, body: body, method: "POST")
        
    }
    func handleRquest(urlString:String,body:Encodable?,method:String)
    {
        do
        {
            
           let bodyData = try body?.andededData()
            if let url = URL(string: urlString)
            {
                print(urlString)
                print("Request Parameters : ")
                print(bodyData?.printString() ?? "")
                var properties = [String:MixpanelType]()
                properties["URL"] = urlString
                if let paramString = bodyData?.getString()   {
                    properties["Request Parameters"] = paramString
                }
                var request = URLRequest(url: url)
                request.httpMethod = method
                request.httpBody = bodyData
                urlSession.dataTask(with: request){ data,response,error in
                    DispatchQueue.main.async {
                        if let errorNonNil = error
                        {
                            self.completion(.failure(errorNonNil))
                            properties["response"] = errorNonNil.localizedDescription

                        }
                        else if let dataNonNil = data
                        {
                            data?.printString()
                            if let responseString = data?.getString()
                            {
                                properties["response"] = responseString
                                
                            }
                            self.completion(.success(dataNonNil))
                        }
                        else
                        {
                            self.completion(.failure(NEError.noData))
                            properties["response"] = NEError.noData.rawValue

                        }
                          Mixpanel.mainInstance().track(event: "API", properties: properties)
                    }
                  
                }.resume()
            }
            else
            {
                
                self.completion(.failure(NEError.noData))
            }
            
        
        }
        catch
        {
            self.completion(.failure(NEError.badParams))

        }
        
        
        
    }
    
    
}
