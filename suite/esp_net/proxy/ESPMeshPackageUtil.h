//
//  ESPMeshPackageUtil.h
//  MeshProxy
//
//  Created by 白 桦 on 4/20/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

/**
 * 00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f 10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f
 * ver   o  flags          proto                   len
 * dst_addr
 *                                                 src_addr
 * ot_len                                          option_list
 *
 *
 * ver: 2 bits, version of mesh;
 * o: 1 bit, exist flag of options in mesh header.
 *
 *
 * flags: 5 bits,
 * 00  01  02  03  04
 * CP  CR  resv
 
 * CP: piggyback congest permit in packet
 * CR: piggyback congest request in packet
 * resv: reserve for future.
 *
 *
 * proto: 8 bits,
 * 00  01  02  03  04  05  06  07
 * D   P2P protocol
 *
 * D: direction of packet(0:downwards, 1:upwards)
 * P2P: Node to Node packet
 * protocol: protocol used by user data
 * current protocol type is as follows:
 * M_PROTO_NONE = 0,
 * M_PROTO_HTTP = 1,
 * M_PROTO_JSON = 2,
 * M_PROTO_MQTT = 3
 *
 * len: 2 bytes, length of mesh packet in bytes(include mesh header)
 * dst_addr: 6 bytes, destiny address
 * proto.D = 0 (downwards) or P2P = 1 (Node-to-Node packet)
 * dst_addr represents the mac address of destiny device
 * Broadcast or multiplecast packet
 * dst_addr represents the broadcast or multiplecast mac address
 * (
 * broadcast:    0x00 0x00 0x00 0x00 0x00 0x00
 * multiplecast: 0x01 0x00 0x5E 0x00 0x00 0x00
 * )
 *
 *
 * src_addr: 6 bytes, source address(for Mobile or Server src_addr could be
 * 0x00 0x00 0x00 0x00 0x00 0x00 and the mesh device will fill in automatically)
 *
 * proto.P2P = 1
 * src_addr represents the mac address of source device
 * Broadcast or multiplecast packet
 * src_addr represents the mac address of source device
 * proto.D = 1(upwards)
 * src_addr represents the mac address of source device
 * proto.D = 0(downwards) and forward packet into mesh
 * src_addr represents the IP and port of Mobile or Server
 *
 *
 * options:
 * ot_len: represent the total length of options (include ot_len field)
 * option_list: the element list of the options
 * otype: 1 Byte, option type
 * olen: 1 Byte, the length of current option
 * ovalue: the value of current option
 *
 * mesh_option_type:
 * M_O_CONGEST_REQ   = 0,
 * M_O_CONGEST_RESP  = 1,
 * M_O_ROUTER_SPREAD = 2,
 * M_O_ROUTER_ADD    = 3,
 * M_O_ROUTER_DEL    = 4,
 * M_O_TOPO_REQ      = 5,
 * M_O_TOPO_RESP     = 6,
 * M_O_MCAST_GRP     = 7,
 * M_O_MESH_FRAG     = 8,
 * M_O_USR_FRAG      = 9,
 * M_O_USER_OPTION   = 10
 *
 * @author afunx
 *
 */

#import <Foundation/Foundation.h>

#define M_OPTION_LEN    2
#define M_HEADER_LEN    16

@interface ESPMeshPackageUtil : NSObject

+ (NSData *) addMeshRequestPackageHeaderByProto:(int)proto TargetBssid:(NSString *)targetBssid RequestData:(NSData *)requestData;

+ (NSData *) addMeshGroupRequestPackageHeaderByProto:(int)proto GroupBssidArray:(NSArray *)groupBssidArray RequestData:(NSData *)requestData;

+ (int) getResponseProto:(NSData *)responseData;

+ (int) getResponsePackageLength:(NSData *)responseData;

+ (int) getResponseOptionLength:(NSData *)responseData;

+ (NSData *) getPureResposneData:(NSData *)responseData;

+ (BOOL) isDeviceAvailable:(NSData *)responseData;

+ (NSString *) getDeviceBssid:(NSData *)responseData;

+ (BOOL) isBodyEmptyByPackageLength:(int)packageLength OptionLength:(int)optionLength;

@end
