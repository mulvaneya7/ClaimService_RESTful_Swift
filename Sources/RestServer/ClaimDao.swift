//
//  ClaimDao.swift
//  
//
//  Created by Alex Mulvaney on 10/25/20.
//

import SQLite3

// Textbook uses JSONSerialization API (in Foundation module)
// JSONEncoder/JSONDecoder

struct Claim : Codable {
    var title : String?
    var date : String?
    
    
    init(tl : String?, dt:String?) {
        title = tl
        date = dt
    }
}

class ClaimDao {
    
    func addClaim(pObj : Claim) {
        let uuid = UUID().uuidString
        let sqlStmt = String(format:"insert into claim (id, title, dateOfClaim, isSolved) values ('%@', '%@', '%@', '%@')", uuid, (pObj.title)!, (pObj.date)!, false)
        // get database connection
        let conn = Database.getInstance().getDbConnection()
        // submit the insert sql statement
        if sqlite3_exec(conn, sqlStmt, nil, nil, nil) != SQLITE_OK {
            let errcode = sqlite3_errcode(conn)
            print("Failed to insert a Claim record due to error \(errcode)")
        }
        // close the connection
        sqlite3_close(conn)
    }
    
    func getAll() -> [Claim] {
        var pList = [Claim]()
        var resultSet : OpaquePointer?
        let sqlStr = "select title, dateOfClaim, isSolved from claim"
        let conn = Database.getInstance().getDbConnection()
        if sqlite3_prepare_v2(conn, sqlStr, -1, &resultSet, nil) == SQLITE_OK {
            while(sqlite3_step(resultSet) == SQLITE_ROW) {
                // Convert the record into a Person object
                // Unsafe_Pointer<CChar> Sqlite3
                let title_val = sqlite3_column_text(resultSet, 0)
                let tl = String(cString: title_val!)
                let date_val = sqlite3_column_text(resultSet, 1)
                let dt = String(cString: date_val!)
                let isSolved_val = sqlite3_column_text(resultSet, 2)
                let iss = String(cString: isSolved_val!)
                pList.append(Claim(tl:tl, dt:dt))
            }
        }
        return pList
    }
}

import Foundation
