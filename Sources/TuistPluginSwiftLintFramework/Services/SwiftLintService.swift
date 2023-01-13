import Foundation
import ProjectAutomation

enum SwiftLintServiceError: Error, CustomStringConvertible, Equatable {
    /// Thrown when a graph can not be found at the given path.
    case graphNotFound
    
    /// Thrown when target with given name does not exist.
    case targetNotFound(targetName: String)
    
    /// Error description.
    var description: String {
        switch self {
        case .graphNotFound:
            return "The project's graph can not be found."
        case .targetNotFound(let targetName):
            return "A target with a name '\(targetName)' not found in the project."
        }
    }
}

/// A service that manages code linting.
public final class SwiftLintService {
    private let swiftLintAdapter: SwiftLintFrameworkAdapting
    
    public init(
        swiftLintAdapter: SwiftLintFrameworkAdapting = SwiftLintFrameworkAdapter()
    ) {
        self.swiftLintAdapter = swiftLintAdapter
    }
    
    #warning("TODO: add unit tests")
    /// The entry point of the service. Invoke it to start linting.
    /// - Parameters:
    ///   - path: The path to the directory that contains the workspace or project whose code will be linted.
    ///   - targetName: The target to be linted. When not specified all the targets of the graph are linted.
    ///   - fix: Correct violations whenever possible.
    ///   - strict: If `true` then warnings will be updated to serious violations (errors).
    public func run(path: String?, targetName: String?, strict: Bool) throws {
        let graph = try getGraph(at: path)
        let sourcesToLint = try getSourcesToLint(in: graph, targetName: targetName)

        if fix {
            #warning("make `configurationFiles` configurable")
            swiftLintAdapter.fix(
                paths: sourcesToLint,
                configurationFiles: [],
                quiet: false
            )
        } else {
            let leniency: Leniency = strict ? .strict : .default

            #warning("make `configurationFiles` configurable")
            #warning("make `leniency` configurable")
            #warning("make `quiet` configurable")
            swiftLintAdapter.lint(
                paths: sourcesToLint,
                configurationFiles: [],
                leniency: leniency,
                quiet: false
            )
        }
    }
    
    #warning("TODO: add unit tests")
    private func getGraph(at path: String?) throws -> Graph {
        do {
            return try Tuist.graph(at: path)
        } catch {
            throw SwiftLintServiceError.graphNotFound
        }
    }
    
    #warning("TODO: add unit tests")
    private func getSourcesToLint(in graph: Graph, targetName: String?) throws -> [String] {
        if let targetName = targetName {
            guard let target = graph.allInternalTargets.first(where: { $0.name == targetName }) else {
                throw SwiftLintServiceError.targetNotFound(targetName: targetName)
            }
            
            return target.sources
        }
        
        return graph.allInternalTargets
            .flatMap { $0.sources }
    }
}

#warning("TODO: add unit tests")
private extension Graph {
    /// Returns a list of targets that are included into the graph and are not 3rd party dependencies.
     var allInternalTargets: [Target] {
         projects.values
             .filter { !$0.isExternal }
             .flatMap { $0.targets }
     }
}
