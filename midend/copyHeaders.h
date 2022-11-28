#ifndef MIDEND_COPYHEADERS_H_
#define MIDEND_COPYHEADERS_H_

#include "frontends/common/resolveReferences/referenceMap.h"
#include "frontends/p4/typeChecking/typeChecker.h"
#include "frontends/p4/typeMap.h"
#include "ir/ir.h"
#include "ir/node.h"
#include "ir/pass_manager.h"
#include "ir/visitor.h"

namespace P4 {

/// Converts assignments of headers, header stacks, and structs into assignments of their
/// individual fields.
///
/// Header assignments are converted into an `if` statement. If the source header is valid, then
/// the validity bit in the destination header is set and the component fields are copied.
/// Otherwise, if the source header is invalid, then the validity bit in the destination header is
/// cleared.
class DoCopyHeaders : public Transform {
    P4::TypeMap* typeMap;

 public:
    explicit DoCopyHeaders(P4::TypeMap* typeMap);
    const IR::Node* postorder(IR::AssignmentStatement* statement) override;
};

class CopyHeaders : public PassRepeated {
 public:
    CopyHeaders(P4::ReferenceMap* refMap, P4::TypeMap* typeMap,
                P4::TypeChecking* typeChecking = nullptr);
};

}  // namespace P4

#endif /* MIDEND_COPYHEADERS_H_ */