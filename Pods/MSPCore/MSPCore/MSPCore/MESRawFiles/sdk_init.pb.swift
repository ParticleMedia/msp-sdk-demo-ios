// DO NOT EDIT.
// swift-format-ignore-file
// swiftlint:disable all
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: mes_events/sdk_init.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

/// sent when app starts up
struct Com_Newsbreak_Mes_Events_SdkInitEvent: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var clientTsMs: UInt64 = 0

  var serverTsMs: UInt64 = 0

  var os: Com_Newsbreak_Monetization_Common_OsType = .unspecified

  var org: String = String()

  var app: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "com.newsbreak.mes.events"

extension Com_Newsbreak_Mes_Events_SdkInitEvent: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".SdkInitEvent"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "client_ts_ms"),
    2: .standard(proto: "server_ts_ms"),
    3: .same(proto: "os"),
    4: .same(proto: "org"),
    5: .same(proto: "app"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularUInt64Field(value: &self.clientTsMs) }()
      case 2: try { try decoder.decodeSingularUInt64Field(value: &self.serverTsMs) }()
      case 3: try { try decoder.decodeSingularEnumField(value: &self.os) }()
      case 4: try { try decoder.decodeSingularStringField(value: &self.org) }()
      case 5: try { try decoder.decodeSingularStringField(value: &self.app) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.clientTsMs != 0 {
      try visitor.visitSingularUInt64Field(value: self.clientTsMs, fieldNumber: 1)
    }
    if self.serverTsMs != 0 {
      try visitor.visitSingularUInt64Field(value: self.serverTsMs, fieldNumber: 2)
    }
    if self.os != .unspecified {
      try visitor.visitSingularEnumField(value: self.os, fieldNumber: 3)
    }
    if !self.org.isEmpty {
      try visitor.visitSingularStringField(value: self.org, fieldNumber: 4)
    }
    if !self.app.isEmpty {
      try visitor.visitSingularStringField(value: self.app, fieldNumber: 5)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Com_Newsbreak_Mes_Events_SdkInitEvent, rhs: Com_Newsbreak_Mes_Events_SdkInitEvent) -> Bool {
    if lhs.clientTsMs != rhs.clientTsMs {return false}
    if lhs.serverTsMs != rhs.serverTsMs {return false}
    if lhs.os != rhs.os {return false}
    if lhs.org != rhs.org {return false}
    if lhs.app != rhs.app {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
