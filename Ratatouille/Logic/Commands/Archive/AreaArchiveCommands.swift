//
//  AreaArchiveCommands.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 03/12/2023.
//

import Foundation
import CoreData

enum AreaArchiveError: Error, LocalizedError {
    case missingIdError(String)
    case unauthorizedError
    case fetchingAreaError
    case areaNotArchivedError
    case archivingError
    case restoreError
    case deleteError
    
    var errorDescription: String? {
        switch self {
        case .missingIdError:
            return NSLocalizedString("Ugyldig id.", comment: "")
        case .unauthorizedError:
            return NSLocalizedString("Du kan kun arkivere dine egne landområder.", comment: "")
        case .fetchingAreaError:
            return NSLocalizedString("Fikk ikke tak i landområde.", comment: "")
        case .areaNotArchivedError:
            return NSLocalizedString("Landområde ligger ikke i arkiv.", comment: "")
        case .archivingError:
            return NSLocalizedString("Kunne ikke arkivere landområde.", comment: "")
        case .restoreError:
            return NSLocalizedString("Kunne ikke gjenopprette landområde.", comment: "")
        case .deleteError:
            return NSLocalizedString("Kunne ikke slette landområde.", comment: "")
        }
    }
}

class LoadAreasFromArchivesCommand: ICommand {
    typealias Input = Void
    typealias Output = [Area]?
    
    func execute(input: Input) async -> Output {
        do {
            let managedObjectContext = DataController.shared.managedObjectContext
            
            let request: NSFetchRequest<Archive> = Archive.fetchRequest()
            let archives = try managedObjectContext.fetch(request)
            
            let areas = archives.compactMap { $0.areas as? Set<Area> }.flatMap { $0 }
            
            return areas
        } catch {
            print("Unexpected error in LoadAreasFromArchivesCommand: \(error)")
            return nil
        }
    }
}

class ArchiveAreaCommand: ICommand {
    typealias Input = Area
    typealias Output = Result<Archive, AreaArchiveError>
    
    func execute(input: Input) async -> Output {
        do {
            // Check for id
            if input.id == nil {
                throw AreaArchiveError.missingIdError("Area ID is missing.")
            }
            
            // Only allow user to archive areas they have created
            for i in 0..<28 {
                if input.id == String(i+1) {
                    throw AreaArchiveError.unauthorizedError
                }
            }
            
            let request: NSFetchRequest<Area> = Area.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", input.id!)
            
            let managedObjectContext = DataController.shared.managedObjectContext
            var result: Output?
            
            try await managedObjectContext.perform {
                if let fetchedArea = try managedObjectContext.fetch(request).first {
                    
                    // check archive
                    let request: NSFetchRequest<Archive> = Archive.fetchRequest()
                    request.predicate = NSPredicate(format: "areas CONTAINS %@", fetchedArea)
                    
                    if let fetchedArchive = try managedObjectContext.fetch(request).first {
                        // Area is already archived
                        result = .success(fetchedArchive)
                    } else {
                        // If no areas has been archived yet, create entity
                        let newArchive = Archive(context: managedObjectContext)
                        newArchive.areas = NSSet(object: fetchedArea)
                        
                        result = .success(newArchive)
                    }
                } else {
                    result = .failure(.fetchingAreaError)
                }
            }
            
            DataController.shared.saveContext()
            
            return result ?? .failure(.archivingError)
            
        } catch {
            print("Unexpected error in ArchiveAreaCommand: \(error)")
            return .failure(error as! AreaArchiveError)
        }
    }
}

class RestoreAreaCommand: ICommand {
    typealias Input = Area
    typealias Output = Result<Area, AreaArchiveError>
    
    func execute(input: Input) async -> Output {
        do {
            // Check for id
            if input.id == nil {
                throw AreaArchiveError.missingIdError("Area ID is missing.")
            }
            
            // Fetch area
            let areaRequest: NSFetchRequest<Area> = Area.fetchRequest()
                areaRequest.predicate = NSPredicate(format: "id == %@", input.id!)
            
            // Variables for restoration
            let managedObjectContext = DataController.shared.managedObjectContext
            var result: Output?
            
            // Perform restoration
            try await managedObjectContext.perform {
                if let fetchedArea = try managedObjectContext.fetch(areaRequest).first {
                    
                    // Check that area is in archives
                    let archiveRequest: NSFetchRequest<Archive> = Archive.fetchRequest()
                        archiveRequest.predicate = NSPredicate(format: "areas CONTAINS %@", fetchedArea)
                    
                    if let archive = try managedObjectContext.fetch(archiveRequest).first {
                        archive.removeFromAreas(fetchedArea) // Remove area from archive
                        result = .success(fetchedArea)
                    } else {
                        result = .failure(.areaNotArchivedError)
                    }
                } else {
                    result = .failure(.fetchingAreaError)
                }
            }
            
            // Save the context after restoration
            print("Restoring area...")
            DataController.shared.saveContext()
                    
            return result ?? .failure(.restoreError)
            
        } catch {
            print("Unexpected error in RestoreAreaCommand: \(error)")
            return .failure(error as! AreaArchiveError)
        }
    }
}

class DeleteAreaCommand: ICommand {
    typealias Input = Area
    typealias Output = Result<Void, AreaArchiveError>
    
    func execute(input: Input) async -> Output {
        do {
            if input.id == nil {
                throw AreaArchiveError.missingIdError("Area ID is missing.")
            }
            
            // Users should not be able to archive certain areas in the first place, so this is better safe than sorry
            for i in 0..<14 {
                if input.id == String(i+1) {
                    throw AreaArchiveError.unauthorizedError
                }
            }
            
            let request: NSFetchRequest<Area> = Area.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", input.id!)
            
            let managedObjectContext = DataController.shared.managedObjectContext
            
            try await managedObjectContext.perform {
                if let fetchedArea = try managedObjectContext.fetch(request).first {
                    
                    let archiveRequest: NSFetchRequest<Archive> = Archive.fetchRequest()
                        archiveRequest.predicate = NSPredicate(format: "areas CONTAINS %@", fetchedArea)
                    
                    if let archivedCategory = try managedObjectContext.fetch(archiveRequest).first {
                        archivedCategory.removeFromAreas(fetchedArea)
                        managedObjectContext.delete(fetchedArea)
                    } else {
                        throw AreaArchiveError.areaNotArchivedError
                    }
                } else {
                    throw AreaArchiveError.fetchingAreaError
                }
            }
            
            DataController.shared.saveContext()
            return .success(())
        } catch {
            print("Unexpected error in DeleteAreaCommand: \(error)")
            return .failure(error as! AreaArchiveError)
        }
    }
}
