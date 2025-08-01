import "@azure-tools/typespec-azure-core";
import "@azure-tools/typespec-azure-resource-manager";
import "@typespec/openapi";
import "@typespec/rest";
import "./models.tsp";
import "./BlobServiceProperties.tsp";

using TypeSpec.Rest;
using Azure.ResourceManager;
using TypeSpec.Http;
using TypeSpec.OpenAPI;

namespace Microsoft.Storage;
/**
 * Properties of the blob container, including Id, resource name, resource type, Etag.
 */
@parentResource(BlobServiceProperties)
model BlobContainer
  is Azure.ResourceManager.ProxyResource<ContainerProperties> {
  ...ResourceNameParameter<
    Resource = BlobContainer,
    KeyName = "containerName",
    SegmentName = "containers",
    NamePattern = ""
  >;
}

@armResourceOperations
interface BlobContainers {
  /**
   * Gets properties of a specified container.
   */
  get is ArmResourceRead<BlobContainer>;

  /**
   * Creates a new container under the specified account as described by request body. The container resource includes metadata and properties for that container. It does not include a list of the blobs contained by the container.
   */
  create is ArmResourceCreateOrReplaceSync<BlobContainer>;

  /**
   * Updates container properties as specified in request body. Properties not mentioned in the request will be unchanged. Update fails if the specified container doesn't already exist.
   */
  @patch(#{ implicitOptionality: false })
  update is ArmCustomPatchSync<BlobContainer, PatchModel = BlobContainer>;

  /**
   * Deletes specified container under its account.
   */
  delete is ArmResourceDeleteSync<BlobContainer>;

  /**
   * Lists all containers and does not support a prefix like data plane. Also SRP today does not return continuation token.
   */
  list is ArmResourceListByParent<
    BlobContainer,
    Parameters = {
      /**
       * Optional. Specified maximum number of containers that can be included in the list.
       */
      @query("$maxpagesize")
      $maxpagesize?: string;

      /**
       * Optional. When specified, only container names starting with the filter will be listed.
       */
      @query("$filter")
      $filter?: string;

      /**
       * Optional, used to include the properties for soft deleted blob containers.
       */
      @query("$include")
      $include?: ListContainersInclude;
    },
    Response = ArmResponse<ListContainerItems>
  >;

  /**
   * Sets legal hold tags. Setting the same tag results in an idempotent operation. SetLegalHold follows an append pattern and does not clear out the existing tags that are not specified in the request.
   */
  setLegalHold is ArmResourceActionSync<
    BlobContainer,
    LegalHold,
    ArmResponse<LegalHold>
  >;

  /**
   * Clears legal hold tags. Clearing the same or non-existent tag results in an idempotent operation. ClearLegalHold clears out only the specified tags in the request.
   */
  clearLegalHold is ArmResourceActionSync<
    BlobContainer,
    LegalHold,
    ArmResponse<LegalHold>
  >;

  /**
   * The Lease Container operation establishes and manages a lock on a container for delete operations. The lock duration can be 15 to 60 seconds, or can be infinite.
   */
  lease is ArmResourceActionSync<
    BlobContainer,
    LeaseContainerRequest,
    ArmResponse<LeaseContainerResponse>,
    OptionalRequestBody = true
  >;

  /**
   * This operation migrates a blob container from container level WORM to object level immutability enabled container. Prerequisites require a container level immutability policy either in locked or unlocked state, Account level versioning must be enabled and there should be no Legal hold on the container.
   */
  @action("migrate")
  objectLevelWorm is ArmResourceActionAsync<BlobContainer, void, OkResponse>;
}

@@maxLength(BlobContainer.name, 63);
@@minLength(BlobContainer.name, 3);
@@doc(BlobContainer.name,
  "The name of the blob container within the specified storage account. Blob container names must be between 3 and 63 characters in length and use numbers, lower-case letters and dash (-) only. Every dash (-) character must be immediately preceded and followed by a letter or number."
);
@@doc(BlobContainer.properties, "Properties of the blob container.");
@@doc(BlobContainers.create::parameters.resource,
  "Properties of the blob container to create."
);
@@doc(BlobContainers.update::parameters.properties,
  "Properties to update for the blob container."
);
@@doc(BlobContainers.setLegalHold::parameters.body,
  "The LegalHold property that will be set to a blob container."
);
@@doc(BlobContainers.clearLegalHold::parameters.body,
  "The LegalHold property that will be clear from a blob container."
);
@@doc(BlobContainers.lease::parameters.body, "Lease Container request body.");
