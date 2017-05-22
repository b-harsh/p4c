#include <core.p4>
#include <v1model.p4>

struct counter_metadata_t {
    bit<16> counter_index;
}

header data_t {
    bit<32> f1;
    bit<32> f2;
    bit<16> h1;
    bit<16> h2;
    bit<16> h3;
    bit<16> h4;
}

struct metadata {
    @name("counter_metadata") 
    counter_metadata_t counter_metadata;
}

struct headers {
    @name("data") 
    data_t data;
}

parser ParserImpl(packet_in packet, out headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name("start") state start {
        packet.extract<data_t>(hdr.data);
        transition accept;
    }
}

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name("count1") @min_width(32) counter(32w16384, CounterType.packets) count1_0;
    @name(".set_index") action set_index_0(bit<16> index, bit<9> port) {
        meta.counter_metadata.counter_index = index;
        standard_metadata.egress_spec = port;
    }
    @name(".count_entries") action count_entries_0() {
        count1_0.count((bit<32>)(bit<14>)meta.counter_metadata.counter_index);
    }
    @name("index_setter") table index_setter_0 {
        actions = {
            set_index_0();
            @defaultonly NoAction();
        }
        key = {
            hdr.data.f1: exact @name("hdr.data.f1") ;
            hdr.data.f2: exact @name("hdr.data.f2") ;
        }
        size = 2048;
        default_action = NoAction();
    }
    @name("stats") table stats_0 {
        actions = {
            count_entries_0();
        }
        default_action = count_entries_0();
    }
    apply {
        index_setter_0.apply();
        stats_0.apply();
    }
}

control egress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    apply {
    }
}

control DeparserImpl(packet_out packet, in headers hdr) {
    apply {
        packet.emit<data_t>(hdr.data);
    }
}

control verifyChecksum(in headers hdr, inout metadata meta) {
    apply {
    }
}

control computeChecksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

V1Switch<headers, metadata>(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;
